defmodule OddishWeb.VisitLive.Show do
  use OddishWeb, :live_view

  alias Oddish.Medicine

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Visita {@visit.id}
        <:subtitle>Este é um registro de visita do seu banco de dados.</:subtitle>
        <:actions>
          <.button navigate={~p"/o/#{@current_scope.organization.slug}/visits"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/o/#{@current_scope.organization.slug}/visits/#{@visit}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Editar visita
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Veterinário">{@visit.vet.name}</:item>
        <:item title="Procedimento">{@visit.procedure.name}</:item>
        <:item title="Pago?">{if @visit.paid?, do: "Sim", else: "Não"}</:item>
        <:item title="Animais">
          <ul class="list-disc pl-4">
            <%= for bovine <- @visit.bovines do %>
              <li>{bovine.registration_number} - {bovine.name}</li>
            <% end %>
          </ul>
        </:item>
        <:item title="Data">{@visit.date}</:item>
        <:item title="Observações">{@visit.notes}</:item>
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
     |> assign(:page_title, "Ver Visita")
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
     |> put_flash(:error, "A visita atual foi excluída.")
     |> push_navigate(to: ~p"/o/#{socket.assigns.current_scope.organization.slug}/visits")}
  end

  def handle_info({type, %Oddish.Medicine.Visit{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
