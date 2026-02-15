defmodule OddishWeb.SoltaLive.Show do
  use OddishWeb, :live_view

  alias Oddish.Soltas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Solta {@solta.id}
        <:actions>
          <.button navigate={~p"/o/#{@current_scope.organization.slug}/soltas"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="soft-primary"
            navigate={~p"/o/#{@current_scope.organization.slug}/grazes/history?solta=#{@solta}"}
          >
            <.icon name="hero-academic-cap" /> Histórico
          </.button>
          <.button
            variant="primary"
            navigate={~p"/o/#{@current_scope.organization.slug}/soltas/#{@solta}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit solta
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Nome">{@solta.name}</:item>
        <:item title="Área">{@solta.area}</:item>
        <:item title="Tipo de capim">{@solta.grass_type}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Soltas.subscribe_soltas(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Detalhes da solta")
     |> assign(:solta, Soltas.get_solta!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Oddish.Soltas.Solta{id: id} = solta},
        %{assigns: %{solta: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :solta, solta)}
  end

  def handle_info(
        {:deleted, %Oddish.Soltas.Solta{id: id}},
        %{assigns: %{solta: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "A solta foi deletada.")
     |> push_navigate(to: ~p"/o/#{socket.assigns.current_scope.organization.slug}/soltas")}
  end

  def handle_info({type, %Oddish.Soltas.Solta{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
