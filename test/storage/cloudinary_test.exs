defmodule ArcTest.Storage.Cloudinary do
  use ExUnit.Case, async: false

  @img "test/support/image.jpg"
  @vid "test/support/video.mp4"
  @url ""
  @videos ~w(.mp4 .mp3)
  @test_dir "test/support/arc_tests"

  setup_all do
    File.mkdir_p(@test_dir)
    Application.put_env(:arc_cloudinary, :supported_video_formats, @videos)

    Application.put_all_env(
      cloudex: [
        api_key: System.get_env("CLOUDEX_API_KEY"),
        secret: System.get_env("CLOUDEX_SECRET"),
        cloud_name: System.get_env("CLOUDEX_CLOUD_NAME")
      ]
    )

    on_exit(fn ->
      File.rm_rf(@test_dir)
    end)
  end

  defmodule TestDefinition do
    use Arc.Definition

    @acl :public_read
    def storage_dir(_, _), do: "test/support/arc_tests"
    def __storage, do: Arc.Storage.Cloudinary
    def signed_urls?, do: false

    def default_transform_opts(file) when is_bitstring(file) do
      ext = Path.extname(file)

      cond do
        ext in [".mp4", ".mp3"] -> %{video_codec: "vc_h265", resource_type: "video"}
        ext in [".png", ".jpg"] -> %{resource_type: "image"}
        true -> %{resource_type: "raw"}
      end
    end

    def default_transform_opts(%{path: file}), do: default_transform_opts(file)
  end

  alias Arc.File
  alias Arc.Storage.Cloudinary

  @tag timeout: 15000
  test "put a local file to storage" do
    id = "random_id#{Enum.random(9999..10000)}"

    assert {:ok, public_id} =
             Cloudinary.put(
               TestDefinition,
               :original,
               {File.new(%{filename: "image.png", path: @img}), %{id: id}}
             )

    assert "#{@test_dir}/#{id}_original" == public_id

    assert {:ok, "http" <> _res} =
             Cloudinary.url(
               TestDefinition,
               :original,
               {File.new(%{filename: "image.png", path: @img}), %{id: id}}
             )
  end

  @tag :vid
  @tag timeout: 15000
  test "put a local video to storage assigning transcoding" do
    id = "random_id_#{Enum.random(99..1000)}"

    Cloudinary.put(
      TestDefinition,
      :original,
      {File.new(%{filename: "video.mp4", path: @vid}), %{id: id}}
    )
    |> IO.inspect(label: "from putting a video")

    # assert "#{@test_dir}/#{id}_original" == public_id

    assert {:ok, "http" <> _res} =
             Cloudinary.url(
               TestDefinition,
               :original,
               {File.new(%{filename: "video.mp4", path: @vid}), %{id: id}}
             )
             |> IO.inspect()
  end

  # test "generation of a url" do
  # end

  # test "deletion of remote file" do
  # end

  # test "transformation of an file" do
  # end
end
