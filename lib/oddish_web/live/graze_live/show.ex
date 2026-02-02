defmodule OddishWeb.GrazeLive.Show do
  use OddishWeb, :live_view

  alias Oddish.Grazes

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Graze {@graze.id}
        <:subtitle>This is a graze record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/o/#{@current_scope.organization.slug}/grazes"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/o/#{@current_scope.organization.slug}/grazes/#{@graze}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit graze
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Flock type">{@graze.flock_type}</:item>
        <:item title="Flock quantity">{@graze.flock_quantity}</:item>
        <:item title="Start date">{@graze.start_date}</:item>
        <:item title="End date">{@graze.end_date}</:item>
        <:item title="Planned period">{@graze.planned_period}</:item>
        <:item title="Status">{@graze.status}</:item>
        <:item title="Solta">{@graze.solta_id}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Grazes.subscribe_grazes(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Graze")
     |> assign(:graze, Grazes.get_graze!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Oddish.Grazes.Graze{id: id} = graze},
        %{assigns: %{graze: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :graze, graze)}
  end

  def handle_info(
        {:deleted, %Oddish.Grazes.Graze{id: id}},
        %{assigns: %{graze: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current graze was deleted.")
     |> push_navigate(to: ~p"/o/#{socket.assigns.current_scope.organization.slug}/grazes")}
  end

  def handle_info({type, %Oddish.Grazes.Graze{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
