defmodule Depentance.Npm do
  require Logger

  alias Depentance.Npm.Package

  def child_spec do
    {Finch, name: __MODULE__, pools: %{"https://registry.npmjs.org/" => [size: 25]}}
  end

  @doc """
  https://github.com/npm/registry/blob/master/docs/responses/package-metadata.md
  """
  def get_package_info(package_name) when is_binary(package_name) do
    Logger.info("Calling NPM Registry for info on pkg #{package_name}")

    {:ok, response} =
      Finch.build(:get, "https://registry.npmjs.org/#{package_name}", [
        "Accept",
        "application/vnd.npm.install-v1+json"
      ])
      |> Finch.request(__MODULE__)

    case response.status do
      200 -> {:ok, Package.from_json(response.body)}
      _ -> {:error, :not_cool}
    end
  end
end
