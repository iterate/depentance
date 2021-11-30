defmodule DepentanceWeb.Live.PackageVersion do
  use Phoenix.Component

  alias Depentance.Npm

  def render(assigns) do
    ~H"""
    <h2><%= @package.name %></h2>
      <%= if @package.description do %>
        <p><%= @package.description %></p>
      <% end %>
      <%= if @package.versions && @selected_version do %>
        <p><%= Npm.Package.get_version(@package, @selected_version) %></p>
      <% end %>
    """
  end
end
