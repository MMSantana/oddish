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
          path={~p"/o/#{@current_scope.organization.slug}/grazes"}
          icon="hero-chart-bar"
          title="Manejo"
          description="Faça a gestão de manejo"
          color="bg-primary"
        />
      </div>

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
          path={~p"/o/#{@current_scope.organization.slug}/packs"}
          icon="hero-globe-europe-africa"
          title="Lotes"
          description="Adicione, remova e edite os lotes"
          color="bg-primary"
        />
      </div>

      <div>
        <.navigation_card
          path={~p"/o/#{@current_scope.organization.slug}/bovines"}
          icon="hero-chart-bar"
          title="Animais"
          description="Aqui você pode gerenciar os animais. Para um nascimento, basta criar um animal com o status ativo.
          Para registrar uma morte, basta criar um animal com o status morto."
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
  attr :color, :string, default: "bg-primary"

  defp navigation_card(assigns) do
    ~H"""
    <.link
      navigate={@path}
      class="card bg-base-100 shadow-xs hover:shadow-2xl hover:bg-base-300 transition-all duration-300 h-full group border border-base-200"
    >
      <div class="card-body p-6">
        <div class="flex items-center gap-4 mb-2">
          <div class={
            [
              "p-3 rounded-xl shadow-sm transition-transform duration-300 group-hover:scale-110",
              # Assuming @color passes something like 'bg-primary' or 'bg-secondary'
              @color
            ]
          }>
            <.icon name={@icon} class="w-8 h-8 text-primary-content" />
          </div>
        </div>

        <h2 class="card-title text-xl text-base-content group-hover:text-primary transition-colors duration-200">
          {@title}
        </h2>

        <p class="text-sm text-base-content/70 mt-2 line-clamp-3">
          {@description}
        </p>

        <div class="card-actions justify-end mt-4">
          <span class="btn btn-ghost btn-sm btn-circle text-primary group-hover:bg-primary group-hover:text-primary-content">
            <.icon name="hero-arrow-right" class="w-4 h-4" />
          </span>
        </div>
      </div>
    </.link>
    """
  end
end
