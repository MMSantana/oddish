defmodule OddishWeb.HomeLive.Home do
  use OddishWeb, :live_view

  def mount(_params, _session, %{assigns: %{current_scope: scope}} = socket) do
    # Cattle
    active_bovines = Oddish.Cattle.count_bovines_by_status(scope, :active)
    births_this_month = Oddish.Cattle.count_bovines_born_this_month(scope)
    departed = Oddish.Cattle.get_departed_bovines_this_month(scope)

    # Packs
    active_packs = Oddish.Packs.count_packs_by_status(scope, :active)
    packs_without_solta = Oddish.Packs.count_packs_without_ongoing_graze(scope)

    # Soltas
    total_soltas = Oddish.Soltas.count_total_soltas(scope)
    empty_soltas = Oddish.Soltas.count_soltas_without_ongoing_graze(scope)
    total_area = Oddish.Soltas.total_solta_area(scope)

    # Medicine
    visits_this_month = Oddish.Medicine.count_visits_this_month(scope)

    # Stocking Rate (Bovines / Hectare)
    stocking_rate =
      if Decimal.compare(total_area, Decimal.new("0.0")) == :gt do
        Decimal.div(Decimal.new(active_bovines), total_area)
        |> Decimal.round(2)
        |> Decimal.to_string()
      else
        "0.00"
      end

    socket =
      socket
      |> assign(:active_bovines, active_bovines)
      |> assign(:active_packs, active_packs)
      |> assign(:packs_without_solta, packs_without_solta)
      |> assign(:total_soltas, total_soltas)
      |> assign(:empty_soltas, empty_soltas)
      |> assign(:births_this_month, births_this_month)
      |> assign(:departed, departed)
      |> assign(:visits_this_month, visits_this_month)
      |> assign(:stocking_rate, stocking_rate)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-7xl mx-auto py-8 font-sans">
        <header class="mb-12 border-b-2 border-base-content/10 pb-6">
          <h1 class="text-4xl font-light tracking-tight text-base-content uppercase">
            Panorama Geral
          </h1>
          <p class="text-sm font-medium text-base-content/50 mt-2 uppercase tracking-widest">
            Visão utilitária do rebanho e infraestrutura
          </p>
        </header>
        
    <!-- General Data Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 border-t border-l border-base-content/10">
          <.metric_block
            title="Bovinos Ativos"
            value={@active_bovines}
            subtitle="No rebanho"
          />

          <.metric_block
            title="Taxa de Lotação"
            value={@stocking_rate}
            subtitle="Cabeças / Hectare"
          />

          <.metric_block
            title="Lotes Ativos"
            value={@active_packs}
            subtitle={
              if @packs_without_solta > 0,
                do: "#{@packs_without_solta} sem solta",
                else: "Todos alocados"
            }
            alert={@packs_without_solta > 0}
          />

          <.metric_block
            title="Soltas Totais"
            value={@total_soltas}
            subtitle={if @empty_soltas > 0, do: "#{@empty_soltas} vazias", else: "Nenhuma vazia"}
          />
        </div>

        <header class="mt-16 mb-8 border-b-2 border-base-content/10 pb-4">
          <h2 class="text-2xl font-light tracking-tight text-base-content uppercase">
            Eventos do Mês
          </h2>
        </header>
        
    <!-- Monthly Events Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 border-t border-l border-base-content/10">
          <.metric_block
            title="Nascimentos"
            value={@births_this_month}
            subtitle="Novos Bezerros"
            value_color="text-emerald-500"
          />

          <.metric_block
            title="Mortes"
            value={@departed.deceased}
            subtitle="Baixas naturais"
            value_color={if @departed.deceased > 0, do: "text-rose-600", else: "text-base-content"}
          />

          <.metric_block
            title="Vendas"
            value={@departed.sold}
            subtitle="Saídas comerciais"
          />

          <.metric_block
            title="Perdas / Roubos"
            value={@departed.lost}
            subtitle="Não encontrados"
            value_color={if @departed.lost > 0, do: "text-amber-500", else: "text-base-content"}
          />

          <.metric_block
            title="Visitas Vet."
            value={@visits_this_month}
            subtitle="Eventos de saúde"
          />
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :title, :string, required: true
  attr :value, :any, required: true
  attr :subtitle, :string, default: nil
  attr :alert, :boolean, default: false
  attr :value_color, :string, default: "text-base-content"

  defp metric_block(assigns) do
    ~H"""
    <div class="p-6 border-r border-b border-base-content/10 flex flex-col justify-between min-h-[160px] bg-base-100/30 hover:bg-base-200/50 transition-colors">
      <h3 class="text-xs font-bold uppercase tracking-widest text-base-content/50 mb-4">
        {"#{@title}"}
      </h3>

      <div>
        <div class={[
          "text-5xl font-light tracking-tighter mb-2",
          @value_color,
          @alert && "!text-error"
        ]}>
          {"#{@value}"}
        </div>

        <%= if @subtitle do %>
          <div class={[
            "text-sm font-medium",
            @alert && "!text-error font-bold",
            !@alert && "text-base-content/60"
          ]}>
            {"#{@subtitle}"}
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
