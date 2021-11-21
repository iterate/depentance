defmodule Depentance.Npm do
  require Logger

  alias Depentance.Npm.Package

  def child_spec do
    {Finch, name: __MODULE__, pools: %{"https://registry.npmjs.org/" => [size: 25]}}
  end

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
