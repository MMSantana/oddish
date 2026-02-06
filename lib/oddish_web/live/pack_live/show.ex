defmodule OddishWeb.PackLive.Show do
  use OddishWeb, :live_view

  alias Oddish.Packs

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Lote {@pack.id}
        <:actions>
          <.button navigate={~p"/o/#{@current_scope.organization.slug}/packs"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/o/#{@current_scope.organization.slug}/packs/#{@pack}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Editar lote
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Nome">{@pack.name}</:item>
        <:item title="Tipo de rebanho">{@pack.flock_type}</:item>
        <:item title="Quantidade de animais">{@pack.animal_count}</:item>
        <:item title="Status">{@pack.status}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Packs.subscribe_packs(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Lote #{id}")
     |> assign(:pack, Packs.get_pack!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Oddish.Packs.Pack{id: id} = pack},
        %{assigns: %{pack: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :pack, pack)}
  end

  def handle_info(
        {:deleted, %Oddish.Packs.Pack{id: id}},
        %{assigns: %{pack: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "O lote foi deletado.")
     |> push_navigate(to: ~p"/o/#{socket.assigns.current_scope.organization.slug}/packs")}
  end

  def handle_info({type, %Oddish.Packs.Pack{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
