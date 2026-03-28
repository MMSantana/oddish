defmodule OddishWeb.VetLive.Show do
  use OddishWeb, :live_view

  alias Oddish.Medicine

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Veterinário {@vet.id}
        <:subtitle>Este é um registro de veterinário do seu banco de dados.</:subtitle>
        <:actions>
          <.button navigate={~p"/o/#{@current_scope.organization.slug}/vets"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/o/#{@current_scope.organization.slug}/vets/#{@vet}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Editar veterinário
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Nome">{@vet.name}</:item>
        <:item title="Telefone">{@vet.telephone}</:item>
        <:item title="Email">{@vet.email}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Medicine.subscribe_vets(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Ver Veterinário")
     |> assign(:vet, Medicine.get_vet!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Oddish.Medicine.Vet{id: id} = vet},
        %{assigns: %{vet: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :vet, vet)}
  end

  def handle_info(
        {:deleted, %Oddish.Medicine.Vet{id: id}},
        %{assigns: %{vet: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "O veterinário atual foi excluído.")
     |> push_navigate(to: ~p"/o/#{socket.assigns.current_scope.organization.slug}/vets")}
  end

  def handle_info({type, %Oddish.Medicine.Vet{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
