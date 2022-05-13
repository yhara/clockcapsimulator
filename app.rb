require 'ovto'

class ClockCapSimulator < Ovto::App
  # Mapping from select id to svg areas.
  AREAS = {
    dial: [1],
    numbers: [2],
    crown: [3],
    base: [4],
    hand: [6],
  }

  # Mapping from color name to svg color.
  # The order is the same as the shopping page.
  COLORS = [
    ["Dead White", "rgb(255,255,255)"],
    ["Moon Yellow", "rgb(255,247,0)"],
    ["Sun Yellow", "rgb(255,231,0)"],
    ["Gold Yellow", "rgb(255,206,0)"],
    ["Orange Gire", "rgb(255,123,0)"],
    ["Hot Orange", "rgb(255,49,8)"],
    ["Bloody Red", "rgb(206,0,24)"],
    ["Gory Red", "rgb(148,0,8)"],
    ["Scarlett Red", "rgb(153,0,51)"],
    ["Squid Pink", "rgb(239,156,181)"],
    ["Warlord Purple", "rgb(156,0,74)"],
    ["Hexed Lichen", "rgb(51, 41, 73)"],
    ["Royal Purple", "rgb(86,47,126)"],
    ["Dark Blue", "rgb(49,99,156)"],
    ["Stormy Blue", "rgb(39,53,126)"],
    ["Night Blue", "rgb(59,77,119)"],
    ["Imperial Blue", "rgb(8,8,90)"],
    ["Magic Blue", "rgb(49,99,156)"],
    ["Ultramarine Blue", "rgb(41,57,123)"],
    ["Electric Blue", "rgb(139,185,221)"],
    ["Turqoise", "rgb(0,107,90)"],
    ["Foul Green", "rgb(130,197,156)"],
    ["Jade Green", "rgb(6,155,125)"],
    ["Scurvy Green", "rgb(2,107,103)"],
    ["Dark Green", "rgb(45,75,64)"],
    ["Sick Green", "rgb(16,107,33)"],
    ["Goblin Green", "rgb(99,181,33)"],
    ["Camouflage Green", "rgb(165,165,66)"],
    ["Escorpena Green", "rgb(76,168,60)"],
    ["Livery Green", "rgb(169,209,113)"],
    ["Bonewhite", "rgb(239,217,168)"],
    ["Dead Flesh", "rgb(231,239,198)"],
    ["Bronze Fleshtone", "rgb(247,148,74)"],
    ["Filthy Brown", "rgb(222,148,8)"],
    ["Scrofulous Brown", "rgb(216,142,45)"],
    ["Plague Brown", "rgb(198,132,0)"],
    ["Leather Brown", "rgb(156,107,8)"],
    ["Dwarf Skin", "rgb(247,140,90)"],
    ["Parasite Brown", "rgb(132,57,16)"],
    ["Beasty Brown", "rgb(102,51,0)"],
    ["Dark Fleshtone", "rgb(99,8,8)"],
    ["Charred Brown", "rgb(57,0,8)"],
    ["Ghost Grey", "rgb(195,198,205)"],
    ["Wolf Grey", "rgb(206,222,231)"],
    ["Sombre Grey", "rgb(71, 91, 119)"],
    ["Stonewall Grey", "rgb(181,181,181)"],
    ["Cold Grey", "rgb(153,153,153)"],
    ["Black", "rgb(1, 6, 6)"],
    ["Silver", "rgb(181,181,189)"],
    ["Chainmal Silver", "rgb(123,115,123)"],
    ["Gunmetal", "rgb(57,57,57)"],
    ["Bright Bronze", "rgb(156,82,33)"],
    ["Brassy Brass", "rgb(115,90,33)"],
    ["Hammered Copper", "rgb(115,55,45)"],
    ["Tinny Tin", "rgb(57,49,33)"],
    ["Kakhi", "rgb(155,140,123)"],
    ["Earth", "rgb(101,81,56)"],
    ["Desert Yellow", "rgb(156,136,85)"],
    ["Yellow Olive", "rgb(6, 59, 46)"],
    ["Terracota", "rgb(121,55,33)"],
    ["Tan", "rgb(169,92,62)"],
    ["Cayman Green", "rgb(69,84,64)"],
    ["Smokey", "rgb(44,24,24)"],
    ["Lavender", "rgb(147,112,219)"],
  ]

  def setup
    colors = state.colors
    begin
      saved = JSON.parse(`localStorage.getItem('colors');`)
      if saved.is_a?(Hash)
        colors = saved
      end
    rescue
      # Just use default
    end
    colors.reverse_each do |part_name, color_idx|
      actions.select_part(part_name: part_name)
      actions.select_color(color_idx: color_idx)
    end
    `setInterval(function(){ #{state.save} }, 1000)`
  end

  class State < Ovto::State
    item :colors, default: AREAS.keys.to_h{|part_name| [part_name, rand(0...COLORS.length)]}
    item :selected_part, default: AREAS.keys.first
    item :selected_color, default: 0

    def color_name(part_name)
      idx = self.colors[part_name]
      COLORS[idx][0]
    end

    def save
      `localStorage.setItem('colors', #{self.colors.to_json});`
    end
  end

  class Actions < Ovto::Actions
    def select_part(part_name:)
      return {selected_part: part_name}
    end

    def select_color(color_idx:)
      Actions.paint(state.selected_part, COLORS[color_idx][1])
      return {
        selected_color: color_idx,
        colors: state.colors.merge({state.selected_part => color_idx})
      }
    end

    # Paint the part with the color
    def self.paint(part_name, svg_color)
      svg = `document.getElementById("clockcap-svg")`
      AREAS[part_name].each do |idx|
        sel = "#clockcap-svg path:nth-child(#{idx})"
        `svg.querySelector(#{sel}).setAttribute("fill", #{svg_color});`
      end
    end
  end

  class MainComponent < Ovto::Component
    def render
      o '#MainComponent' do
        AREAS.each_key do |part_name|
          o PartSelector, part_name: part_name
        end
        o ColorList
        #o 'pre#debug', state.to_h.inspect
      end
    end

    class PartSelector < Ovto::Component
      def render(part_name:)
        o '.PartSelector' do
          o 'input', {
            type: 'radio',
            id: part_name,
            value: part_name,
            onchange: ->(e){ actions.select_part(part_name: e.target.value) },
            checked: state.selected_part == part_name,
          }
          o 'label', {
            for: part_name,
          }, "[#{part_name.capitalize}] #{state.color_name(part_name)}"
        end
      end
    end

    class ColorList < Ovto::Component
      def render
        o '.ColorList', {
          style: {
            display: :flex,
            "flex-wrap": :wrap,
          },
        } do
          COLORS.each.with_index do |(_, rgb), i|
            o ColorPicker, rgb: rgb, idx: i
          end
        end
      end

      class ColorPicker < Ovto::Component
        def render(rgb:, idx:)
          style = {
            width: '20px',
            height: '20px',
            background: rgb,
          }
          if state.selected_color == idx
            style["border-radius"] = "10px"
          end
          o '.ColorPicker', {
            style: style,
            onclick: ->(e){ actions.select_color(color_idx: idx) },
          }, ''
        end
      end
    end
  end
end

ClockCapSimulator.run(id: 'ovto')
