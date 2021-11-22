defimpl Phoenix.HTML.Safe, for: Version do
  def to_iodata(version) do
    to_string(version)
  end
end
