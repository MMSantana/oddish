defmodule OddishWeb.HomeLive.Home do
  use OddishWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div>
        <.navigation_card
          path={~p"/o/#{@current_scope.organization.slug}/soltas"}
          icon="hero-globe-europe-africa"
          title="Soltas"
          description="Adicione, remova e edite as soltas"
          color="bg-primary"
        />
      </div>

      <div>
        <.navigation_card
          path={~p"/o/#{@current_scope.organization.slug}/grazes"}
          icon="hero-chart-bar"
          title="Manejo"
          description="Faça a gestão de manejo"
          color="bg-primary"
        />
      </div>

      <div>
        <.navigation_card
          path={~p"/o/#{@current_scope.organization.slug}/bovines"}
          icon="hero-chart-bar"
          title="Bovinos"
          description="Aqui você pode gerenciar os bois. Para um nascimento, basta criar um boi com o status ativo.
          Para registrar uma morte, basta criar um boi com o status morto."
          color="bg-primary"
        />
      </div>
    </Layouts.app>
    """
  end

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :icon, :string, required: true
  attr :path, :string, required: true
  attr :color, :string, default: "blue"

  defp navigation_card(assigns) do
    ~H"""
    <.link
      navigate={@path}
      class="block card bg-base-100 shadow-xl hover:shadow-2xl hover:bg-gray-50 transition-all duration-200 rounded-lg h-full"
    >
      <div class="card-body grow flex flex-col">
        <div class="flex items-center gap-3 mb-4">
          <div class={[
            "p-3 rounded-lg transition-colors duration-200",
            @color
          ]}>
            <.icon name={@icon} class="w-8 h-8 text-white" />
          </div>
        </div>

        <h2 class="card-title text-xl group-hover:text-blue-600 transition-colors duration-200 wrap-break-words">
          {@title}
        </h2>

        <p class="text-sm text-gray-500 grow mt-2 wrap-break-words">
          {@description}
        </p>
      </div>
    </.link>
    """
  end
end
