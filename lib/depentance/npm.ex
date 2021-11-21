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

  def get_info(package_name) do
    :get
    |> Finch.build("https://registry.npmjs.org/#{package_name}")
    |> Finch.request(__MODULE__)
  end

  def get_package(package_name) do
    {:ok, response} =
      Finch.build(:get, "https://registry.npmjs.org/#{package_name}")
      |> Finch.request(__MODULE__)

    case response.status do
      200 -> Package.from_json(response.body)
      _ -> nil
    end
  end

  def get_versions(package_name) do
    {:ok, response} = get_info(package_name)

    response.body
    |> Jason.decode!()
    |> case do
      %{"versions" => versions} -> versions
      _ -> nil
    end
    |> Enum.map(fn {k, _v} -> Version.parse!(k) end)
    |> Enum.sort(:desc)
  end

  def info(package_name, version \\ nil) do
    package_ref = if version, do: "#{package_name}@#{version}", else: package_name

    case System.cmd("npm", ["info", "--json", package_ref], stderr_to_stdout: true) do
      {result, 0} ->
        Logger.info("Calling NPM INFO for pkg #{package_ref}...OK")
        {:ok, Jason.decode!(result)}

      {err, 1} ->
        Logger.info("Calling NPM INFO for pkg #{package_ref}...NOT OK")
        {:error, err}
    end
  end
end

defimpl Phoenix.HTML.Safe, for: Version do
  def to_iodata(version) do
    [version.major, version.minor, version.patch] |> Enum.join(".")
  end
end
