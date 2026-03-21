defmodule OddishWeb.VisitLive.Show do
  use OddishWeb, :live_view

  alias Oddish.Medicine

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Visit {@visit.id}
        <:subtitle>This is a visit record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/o/#{@current_scope.organization.slug}/visits"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/o/#{@current_scope.organization.slug}/visits/#{@visit}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit visit
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Vet">{@visit.vet_id}</:item>
        <:item title="Procedure">{@visit.procedure_id}</:item>
        <:item title="Bovine">{@visit.bovine_id}</:item>
        <:item title="Date">{@visit.date}</:item>
        <:item title="Notes">{@visit.notes}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Medicine.subscribe_visits(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Visit")
     |> assign(:visit, Medicine.get_visit!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Oddish.Medicine.Visit{id: id} = visit},
        %{assigns: %{visit: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :visit, visit)}
  end

  def handle_info(
        {:deleted, %Oddish.Medicine.Visit{id: id}},
        %{assigns: %{visit: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current visit was deleted.")
     |> push_navigate(to: ~p"/o/#{socket.assigns.current_scope.organization.slug}/visits")}
  end

  def handle_info({type, %Oddish.Medicine.Visit{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
