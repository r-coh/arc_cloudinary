defmodule ArcTest.Storage.Cloudinary do
  use ExUnit.Case, async: false
  @img "test/support/image.png"
  @vid "test/support/video.mp4"

  defmodule DummyDefination do
    use Arc.Definition

    def __storage, do: Arc.Storage.Cloudinary
    def storage_dir(_, _), do: "arctest/uploads"
  end

  defmodule DefinitionWithThumbnail do
    use Arc.Definition
    @version [:thumb]

    def __storage, do: Arc.Storage.Cloudinary

    def transform(:thumb, _) do
      {"convert", "-strip -thumbnail 100x100^ -gravity center -extent 100x100 -format jpg", :jpg}
    end
  end

  defmodule DefinitionWithScope do
    use Arc.Definition
    def __storage, do: Arc.Storage.Cloudinary
    def storage_dir(_, {_, scope}), do: "uploads/with_scopers/#{scope.id}"
  end

  test "put a file to storage" do
    assert
  end

  test "generation of a url" do

  end

  test "deletion of remote file" do

  end

  test "transformation of an file" do

  end
end
