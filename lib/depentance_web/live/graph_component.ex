defmodule DepentanceWeb.GraphComponent do
  use Phoenix.Component

  def graph(assigns) do
    ~H"""
    <ul>
      <%= for version <- @package.versions do %>
        <li><%= version %></li>
      <% end %>
    </ul>
    """
  end
end
