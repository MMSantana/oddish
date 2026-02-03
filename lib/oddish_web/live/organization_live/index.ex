defmodule OddishWeb.OrganizationLive.Index do
  use OddishWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <h1>Organização</h1>
      <ul>
        <%= for org <- @org_list do %>
          <li><.link navigate={~p"/o/#{org.slug}"}>{org.slug}</.link></li>
        <% end %>
      </ul>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    socket =
      assign(socket, org_list: Oddish.Accounts.Organization.get_organizations_by_user(scope))

    {:ok, socket}
  end
end
