defmodule Arc.Storage.Cloudinary do
  @moduledoc false

  def put(definition, version, {file, scope}) do
    dest_dir = definition.storage_dir(version, {file, scope})
    file_type = file_type(file)
    public_id = "#{dest_dir}/#{scope.id}_#{version}"
    file_opts = [resource_type: file_type, public_id: public_id, tags: scope.id]
    default_opts = definition.default_transform_opts(file) |> Map.to_list()
    upload_opts = file_opts ++ default_opts

    case upload_file(file, upload_opts) do
      {:ok, conn} -> {:ok, conn.public_id}
      {:error, conn} -> {:error, conn}
    end
  end

  def url(definition, version, file_and_scope, opts \\ []) do
    {file, scope} = file_and_scope
    dest_dir = definition.storage_dir(version, file_and_scope)
    public_id = "#{dest_dir}/#{scope.id}_#{version}"

    transform_opts = file |> definition.default_transform_opts() |> Map.merge(Map.new(opts))

    case resolve_url(public_id, transform_opts) do
      {:ok, url} -> {:ok, append_missing_details(url, definition, version, file_and_scope)}
      {:error, _} -> {:error, ""}
    end
  end

  def delete(definition, version, {file, scope}) do
    dest_dir = definition.storage_dir(version, {file, scope})
    public_id = "#{dest_dir}/#{scope.id}_#{version}"
    Cloudex.delete(public_id)
  end

  #
  # PRIVATE
  #
  defp resolve_url(id, opts) do
    {:ok, Cloudex.Url.for(id, opts)}
  end

  defp append_missing_details(url, definition, version, {%{path: file}, scope}),
    do: append_missing_details(url, definition, version, {file, scope})

  defp append_missing_details(url, definition, _version, {file, _scope}) do
    scheme =
      case definition.signed_urls? do
        true -> "https:"
        false -> "http:"
      end

    scheme <> url <> Path.extname(file)
  end

  defp supported_video_formats,
    do: Application.get_env(:arc_cloudinary, :supported_video_ext, [".mp3"])

  defp default_transformation_presets,
    do: Application.get_env(:arc_cloudinary, :default_presets, [])

  defp upload_file(%{path: path}, opts), do: upload_file(path, opts)
  defp upload_file(file, opts) when is_map(opts), do: upload_file(file, Map.to_list(opts))

  defp upload_file(file, opts) when is_list(opts) and is_binary(file),
    do: Cloudex.upload(file, Map.new(opts))

  defp file_type(file) when is_bitstring(file) do
    videos = supported_video_formats()
    ext = Path.extname(file)

    cond do
      ext in videos -> "video"
      true -> "image"
    end
  end

  defp file_type(%{path: file}), do: file_type(file)
end
