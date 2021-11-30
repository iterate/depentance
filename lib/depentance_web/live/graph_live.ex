defmodule DepentanceWeb.GraphLive do
  require Logger
  use DepentanceWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        input_name: nil,
        version_input: nil,
        package: nil,
        index: %{package: 0, version: 0},
        package_version: nil
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
      <%= if @package_version do %>
        <DepentanceWeb.Live.PackageVersion.render package_version={@package_version} />
      <% else %>
        <DepentanceWeb.Live.PackageOverview.render package={@package} />
      <% end %>
    <% end %>
    """
  end

  def handle_cast(
        {:set_package, package, msg_index},
        %{assigns: %{index: %{package: pkg_index} = index}} = socket
      )
      when msg_index > pkg_index do
    socket =
      cond do
        package && package.name == socket.assigns.input_name ->
          assign(socket,
            package: package,
            version_input: List.first(package.versions),
            index: %{index | package: pkg_index}
          )

        package == nil ->
          assign(socket,
            package: nil,
            version_input: nil,
            index: %{index | package: pkg_index}
          )

        true ->
          socket
      end

    {:noreply, socket}
  end

  def handle_cast(
        {:set_package_version, package_version, msg_index},
        %{assigns: %{index: %{version: vrsn_index} = index}} = socket
      )
      when msg_index > vrsn_index do
    socket =
      cond do
        package_version && package_version.name == socket.assigns.input_name ->
          assign(socket,
            package_version: package_version,
            index: %{index | version: vrsn_index}
          )

        package_version == nil ->
          assign(socket,
            package_version: nil,
            index: %{index | version: vrsn_index}
          )

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
    live_pid = self()

    spawn(fn ->
      response = Depentance.Npm.get_package_version_info(socket.assigns.package.name, version)

      case response do
        {:ok, package_version} ->
          GenServer.cast(
            live_pid,
            {:set_package_version, package_version, socket.assigns.index.version + 1}
          )

        _ ->
          nil
      end
    end)

    {:noreply, assign(socket, version_input: version)}
  end

  def handle_event("set-package-input-name", %{"name" => name}, socket) do
    live_pid = self()

    spawn(fn ->
      response = Depentance.Npm.get_package_info(name)

      case response do
        {:ok, package} ->
          GenServer.cast(live_pid, {:set_package, package, socket.assigns.index.package + 1})

        _ ->
          nil
      end
    end)

    {:noreply, assign(socket, input_name: name)}
  end
end
