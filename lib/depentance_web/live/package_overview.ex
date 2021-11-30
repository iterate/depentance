defmodule DepentanceWeb.Live.PackageOverview do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <h2><%= @package.name %></h2>
      <%= if @package.description do %>
        <p><%= @package.description %></p>
      <% end %>
    """
  end
end
