defmodule OddishWeb.VisitLive.Index do
  use OddishWeb, :live_view

  alias Oddish.Medicine

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Visits
        <:actions>
          <.button variant="primary" navigate={~p"/o/#{@current_scope.organization.slug}/visits/new"}>
            <.icon name="hero-plus" /> New Visit
          </.button>
        </:actions>
      </.header>

      <.table
        id="visits"
        rows={@streams.visits}
        row_click={
          fn {_id, visit} ->
            JS.navigate(~p"/o/#{@current_scope.organization.slug}/visits/#{visit}")
          end
        }
      >
        <:col :let={{_id, visit}} label="Vet">{visit.vet_id}</:col>
        <:col :let={{_id, visit}} label="Procedure">{visit.procedure_id}</:col>
        <:col :let={{_id, visit}} label="Bovine">{visit.bovine_id}</:col>
        <:col :let={{_id, visit}} label="Date">{visit.date}</:col>
        <:col :let={{_id, visit}} label="Notes">{visit.notes}</:col>
        <:action :let={{_id, visit}}>
          <div class="sr-only">
            <.link navigate={~p"/o/#{@current_scope.organization.slug}/visits/#{visit}"}>Show</.link>
          </div>
          <.link navigate={~p"/o/#{@current_scope.organization.slug}/visits/#{visit}/edit"}>
            Edit
          </.link>
        </:action>
        <:action :let={{id, visit}}>
          <.link
            phx-click={JS.push("delete", value: %{id: visit.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Medicine.subscribe_visits(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Visits")
     |> stream(:visits, list_visits(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    visit = Medicine.get_visit!(socket.assigns.current_scope, id)
    {:ok, _} = Medicine.delete_visit(socket.assigns.current_scope, visit)

    {:noreply, stream_delete(socket, :visits, visit)}
  end

  @impl true
  def handle_info({type, %Oddish.Medicine.Visit{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :visits, list_visits(socket.assigns.current_scope), reset: true)}
  end

  defp list_visits(current_scope) do
    Medicine.list_visits(current_scope)
  end
end
