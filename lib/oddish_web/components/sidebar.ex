defmodule OddishWeb.Sidebar do
  @moduledoc """
  Sidebar navigation component for the application.
  """
  use OddishWeb, :html

  @doc """
  Renders the sidebar navigation with links to main sections.

  Only displays when there is a current organization in scope.
  """
  attr :current_scope, :map, required: true

  def sidebar(assigns) do
    ~H"""
    <%= if @current_scope && @current_scope.organization do %>
      <aside
        class="bg-slate-50 border-r border-slate-200 overflow-y-auto overflow-x-hidden flex flex-col pt-4 pb-6 h-full transition-all duration-300 ease-in-out z-20"
        x-bind:class="sidebarOpen ? 'w-64' : 'w-0 border-r-0 opacity-0'"
      >
        <div class="px-4 mb-6 transition-all duration-300 whitespace-nowrap">
          <div class="flex items-center gap-3 px-2 py-3">
            <div class="bg-blue-600 text-white rounded-md shrink-0 p-1.5 flex items-center justify-center shadow-sm">
              <.icon name="hero-building-office-2" class="size-6 text-white" />
            </div>

            <div class="flex items-center gap-2 flex-1">
              <span class="font-semibold text-slate-900 truncate">
                {@current_scope.organization.name}
              </span>
            </div>
          </div>
        </div>

        <nav class="flex-1 px-4 space-y-6 transition-all duration-300 whitespace-nowrap">
          <div>
            <h3 class="px-3 mb-2 text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Fazenda
            </h3>

            <ul class="space-y-1">
              <li>
                <.link
                  href={~p"/o/#{@current_scope.organization.slug}/soltas"}
                  title="Soltas"
                  class="flex items-center gap-3 px-3 py-2 rounded-md text-slate-700 hover:bg-slate-200/50 hover:text-slate-900 transition-colors group relative"
                >
                  <.icon
                    name="hero-play-circle"
                    class="shrink-0 size-5 text-slate-400 group-hover:text-blue-600 transition-colors"
                  />
                  <span class="font-medium text-sm">Soltas</span>
                </.link>
              </li>
              <li>
                <.link
                  href={~p"/o/#{@current_scope.organization.slug}/grazes"}
                  title="Manejo"
                  class="flex items-center gap-3 px-3 py-2 rounded-md text-slate-700 hover:bg-slate-200/50 hover:text-slate-900 transition-colors group relative"
                >
                  <.icon
                    name="hero-play-circle"
                    class="shrink-0 size-5 text-slate-400 group-hover:text-blue-600 transition-colors"
                  />
                  <span class="font-medium text-sm">Manejo</span>
                </.link>
              </li>
            </ul>
          </div>

          <div>
            <h3 class="px-3 mb-2 text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Animais
            </h3>

            <ul class="space-y-1">
              <li>
                <.link
                  href={~p"/o/#{@current_scope.organization.slug}/bovines"}
                  title="Animais"
                  class="flex items-center gap-3 px-3 py-2 rounded-md text-slate-700 hover:bg-slate-200/50 hover:text-slate-900 transition-colors group relative"
                >
                  <.icon
                    name="hero-wrench-screwdriver"
                    class="shrink-0 size-5 text-slate-400 group-hover:text-slate-600 transition-colors"
                  />
                  <span class="font-medium text-sm">Animais</span>
                </.link>
              </li>
              <li>
                <.link
                  href={~p"/o/#{@current_scope.organization.slug}/packs"}
                  title="Rebanhos"
                  class="flex items-center gap-3 px-3 py-2 rounded-md text-slate-700 hover:bg-slate-200/50 hover:text-slate-900 transition-colors group relative"
                >
                  <.icon
                    name="hero-user-group"
                    class="shrink-0 size-5 text-slate-400 group-hover:text-slate-600 transition-colors"
                  />
                  <span class="font-medium text-sm">Lotes</span>
                </.link>
              </li>
            </ul>
          </div>

          <div>
            <h3 class="px-3 mb-2 text-xs font-semibold text-slate-500 uppercase tracking-wider">
              Veterinária
            </h3>

            <ul class="space-y-1">
              <li>
                <.link
                  href={~p"/o/#{@current_scope.organization.slug}/visits"}
                  title="Visitas"
                  class="flex items-center gap-3 px-3 py-2 rounded-md text-slate-700 hover:bg-slate-200/50 hover:text-slate-900 transition-colors group relative"
                >
                  <.icon
                    name="hero-wrench-screwdriver"
                    class="shrink-0 size-5 text-slate-400 group-hover:text-slate-600 transition-colors"
                  />
                  <span class="font-medium text-sm">Visitas</span>
                </.link>
              </li>
              <li>
                <.link
                  href={~p"/o/#{@current_scope.organization.slug}/procedures"}
                  title="Procedimentos"
                  class="flex items-center gap-3 px-3 py-2 rounded-md text-slate-700 hover:bg-slate-200/50 hover:text-slate-900 transition-colors group relative"
                >
                  <.icon
                    name="hero-user-group"
                    class="shrink-0 size-5 text-slate-400 group-hover:text-slate-600 transition-colors"
                  />
                  <span class="font-medium text-sm">Procedimentos</span>
                </.link>
              </li>
              <li>
                <.link
                  href={~p"/o/#{@current_scope.organization.slug}/vets"}
                  title="Veterinários"
                  class="flex items-center gap-3 px-3 py-2 rounded-md text-slate-700 hover:bg-slate-200/50 hover:text-slate-900 transition-colors group relative"
                >
                  <.icon
                    name="hero-document-text"
                    class="shrink-0 size-5 text-slate-400 group-hover:text-slate-600 transition-colors"
                  />
                  <span class="font-medium text-sm">Veterinários</span>
                </.link>
              </li>
            </ul>
          </div>
        </nav>
      </aside>
    <% end %>
    """
  end
end
