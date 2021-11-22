defmodule DepentanceWeb.GraphLive do
  require Logger
  use DepentanceWeb, :live_view

  alias Depentance.Npm

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        input_name: nil,
        version_input: nil,
        package: nil,
        index: 0
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>depentance</h1>
    <p>do not worry and embrace the graph</p>
    <form phx-change="set-package-input-name">
      <input type="text" name="name" value={@input_name} />
      <%= if @package do %>
      <select name="version">
        <%= for version <- @package.versions do %>
          <option value={version}><%= version %></option>
        <% end %>
      </select>
      <% end %>
    </form>
    <br />
    <%= if @package do %>
     <h2><%= @package.name %></h2>
     <p><%= @package.description %></p>
     <p><%= Npm.Package.get_version(@package, @version_input) %> </p>
    <% end %>
    """
  end

  def handle_cast({:set_package, package, msg_index}, %{assigns: %{index: index}} = socket)
      when msg_index > index do
    socket =
      cond do
        package && package.name == socket.assigns.input_name ->
          assign(socket, package: package, version_input: List.first(package.versions))

        package == nil ->
          assign(socket, package: nil, version_input: nil)

        true ->
          socket
      end

    {:noreply, socket}
  end

  def handle_event(
        "set-package-input-name",
        %{"_target" => ["version"], "version" => version},
        socket
      ) do
    {:noreply, assign(socket, version_input: version)}
  end

  def handle_event("set-package-input-name", %{"name" => name}, socket) do
    live_pid = self()

    spawn(fn ->
      response = Depentance.Npm.get_package_info(name)

      case response do
        {:ok, package} ->
          GenServer.cast(live_pid, {:set_package, package, socket.assigns.index + 1})

        _ ->
          Logger.warn("Could not get package #{name}")
      end
    end)

    {:noreply, assign(socket, input_name: name)}
  end
end
