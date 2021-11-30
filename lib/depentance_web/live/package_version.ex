defmodule DepentanceWeb.Live.PackageVersion do
  use Phoenix.Component

  alias Depentance.Npm

  def render(assigns) do
    ~H"""
    <h2><%= @package_version.name %></h2>
      <%= if @package_version.version do %>
        <p><%= @package_version.version %></p>
      <% end %>
      <%= if @package_version.deprecated do %>
        <p class="deprecated"><%= @package_version.deprecated %></p>
      <% end %>      <%= if @package_version.description do %>
        <p><%= @package_version.description %></p>
      <% end %>

    """
  end
end
