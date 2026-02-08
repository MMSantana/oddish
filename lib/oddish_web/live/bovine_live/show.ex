defmodule OddishWeb.BovineLive.Show do
  use OddishWeb, :live_view

  alias Oddish.Cattle

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Animal {@bovine.id}
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
            <.icon name="hero-pencil-square" /> Editar
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Nome">{@bovine.name}</:item>
        <:item title="Número de registro">{@bovine.registration_number}</:item>
        <:item title="Gênero">{Oddish.Cattle.Bovine.present_gender(@bovine.gender)}</:item>
        <:item title="Mãe">{@bovine.mother_id}</:item>
        <:item title="Data de nascimento">{@bovine.date_of_birth}</:item>
        <:item title="Descrição">{@bovine.description}</:item>
        <:item title="Observação">{@bovine.observation}</:item>
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
     |> assign(:page_title, "Animal")
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
     |> put_flash(:error, "O animal atual foi deletado.")
     |> push_navigate(to: ~p"/o/#{socket.assigns.current_scope.organization.slug}/bovines")}
  end

  def handle_info({type, %Oddish.Cattle.Bovine{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
