defmodule Depentance.Npm do
  require Logger

  defmodule Package do
    defstruct [:name, :description, :versions]

    def from_json(json) do
      map = Jason.decode!(json)

      if map["name"] do
        name = map["name"]
        description = map["description"]
        versions = map["versions"] |> Enum.map(fn {k, _v} -> Version.parse!(k) end) |> Enum.sort()

        %Package{name: name, description: description, versions: versions}
      else
        nil
      end
    end
  end

  def child_spec do
    {Finch, name: __MODULE__, pools: %{"https://registry.npmjs.org/" => [size: pool_size()]}}
  end

  def pool_size, do: 25

  def get_package(package_name) do
    Logger.info("Calling NPM Registry for info on pkg #{package_name}")

    {:ok, response} =
      Finch.build(:get, "https://registry.npmjs.org/#{package_name}")
      |> Finch.request(__MODULE__)

    case response.status do
      200 -> Package.from_json(response.body)
      _ -> nil
    end
  end
end

defimpl Phoenix.HTML.Safe, for: Version do
  def to_iodata(version) do
    [version.major, version.minor, version.patch] |> Enum.join(".")
  end
end
