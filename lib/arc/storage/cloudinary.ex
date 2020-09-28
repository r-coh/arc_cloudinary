defmodule Arc.Storage.Cloudinary do
  @moduledoc false

  def put(defination, version, {file, scope}) do
    dest_dir = defination.storage_dir(version, {file, scope})
    file_type = file_type(file)
    public_id = "#{dest_dir}/#{scope.id}_#{version}"
    file_opts = [resource_type: file_type, public_id: public_id]
    default_opts = default_transformation_presets()
    upload_opts = file_opts ++ default_opts

    case upload_file(file, upload_opts) do
      {:ok, _conn} -> {:ok, file.public_id}
      {:error, conn} -> {:error, conn}
    end
  end

  #
  # PRIVATE
  #

  defp supported_video_formats,
    do: Application.get_env(:arc_cloudinary, :supported_video_ext, [".mp3"])

  defp default_transformation_presets,
    do: Application.get_env(:arc_cloudinary, :default_presets, [])

  defp upload_file(%{path: path}, opts), do: upload_file(path, opts)
  defp upload_file(file, opts) when is_map(opts), do: upload_file(file, Map.to_list(opts))

  defp upload_file(file, opts) when is_list(opts) and is_binary(file),
    do: Cloudex.upload(file, Map.new(opts))

  defp file_type(file) do
    videos = supported_video_formats()
    ext = Path.extname(file)

    cond do
      ext in videos -> "video"
      true -> "image"
    end
  end
end
