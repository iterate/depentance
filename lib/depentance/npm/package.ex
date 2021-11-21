defmodule Depentance.Npm.Package do
  defstruct [:name, :description, :versions]
  alias Depentance.Npm.Package

  def from_json(json) do
    map = Jason.decode!(json)

    if map["name"] do
      name = map["name"]
      description = map["description"]

      versions =
        map["versions"] |> Enum.map(fn {k, _v} -> Version.parse!(k) end) |> Enum.sort(:desc)

      %Package{name: name, description: description, versions: versions}
    else
      nil
    end
  end

  def get_version(%Package{versions: versions}, %Version{} = version) do
    Enum.find(versions, &(&1 == version))
  end

  def get_version(%Package{} = package, version) when is_binary(version) do
    get_version(package, Version.parse!(version))
  end
end
