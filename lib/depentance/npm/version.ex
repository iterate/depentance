defmodule Depentance.Npm.Package.Version do
  defstruct [:name, :description, :version, :deprecated]
  alias Depentance.Npm.Package

  def from_json(json) do
    map = Jason.decode!(json)

    if map["name"] do
      name = map["name"]
      description = map["description"]
      version = map["version"] |> Version.parse!()
      deprecated = map["deprecated"]

      %Package.Version{
        name: name,
        description: description,
        version: version,
        deprecated: deprecated
      }
    else
      nil
    end
  end
end
