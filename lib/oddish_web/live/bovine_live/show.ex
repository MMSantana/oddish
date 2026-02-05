defmodule OddishWeb.BovineLive.Show do
  use OddishWeb, :live_view

  alias Oddish.Cattle

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Bovine {@bovine.id}
        <:subtitle>This is a bovine record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/o/#{@current_scope.organization.slug}/bovines"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={
              ~p"/o/#{@current_scope.organization.slug}/bovines/#{@bovine}/edit?return_to=show"
            }
          >
            <.icon name="hero-pencil-square" /> Edit bovine
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@bovine.name}</:item>
        <:item title="Registration number">{@bovine.registration_number}</:item>
        <:item title="Gender">{@bovine.gender}</:item>
        <:item title="Mother">{@bovine.mother_id}</:item>
        <:item title="Date of birth">{@bovine.date_of_birth}</:item>
        <:item title="Description">{@bovine.description}</:item>
        <:item title="Observation">{@bovine.observation}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Cattle.subscribe_bovines(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Bovine")
     |> assign(:bovine, Cattle.get_bovine!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Oddish.Cattle.Bovine{id: id} = bovine},
        %{assigns: %{bovine: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :bovine, bovine)}
  end

  def handle_info(
        {:deleted, %Oddish.Cattle.Bovine{id: id}},
        %{assigns: %{bovine: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current bovine was deleted.")
     |> push_navigate(to: ~p"/o/#{socket.assigns.current_scope.organization.slug}/bovines")}
  end

  def handle_info({type, %Oddish.Cattle.Bovine{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
