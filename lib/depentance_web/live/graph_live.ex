defmodule Package do
  import Ecto.Changeset

  defstruct name: ""

  def changeset(package, params \\ %{}) do
    types = %{name: :string}

    {package, types}
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end

defmodule DepentanceWeb.GraphLive do
  use DepentanceWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        package_input: Package.changeset(%Package{}),
        package: nil
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>depentance</h1>
    do not worry and embrace the graph
    <br />
    <.form let={f} for={@package_input} phx-change="set-package">
      <%= label f, :name %>
      <%= text_input f, :name %>
      <%= if @package do %>
        <%= label f, :version %>
        <%= select f, :version, @package.versions |> Enum.map(&Phoenix.HTML.Safe.to_iodata/1) %>
      <% end %>
    </.form>
    <br />
    <%= if @package do %>
     <h2><%= @package.name %></h2>
     <p><%= @package.description %></p>
     <DepentanceWeb.GraphComponent.graph package={@package} />
    <% end %>
    """
  end

  def handle_event("set-package", %{"package" => params}, socket) do
    package = Depentance.Npm.get_package(params["name"])

    socket = assign(socket, package: package)
    {:noreply, socket}
  end
end
