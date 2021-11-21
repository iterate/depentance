defimpl Phoenix.HTML.Safe, for: Version do
  def to_iodata(version) do
    [version.major, version.minor, version.patch] |> Enum.join(".")
  end
end
