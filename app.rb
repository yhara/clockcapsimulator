require 'ovto'

class ClockCapSimulator < Ovto::App
  # Mapping from select id to svg areas.
  AREAS = {
    dial: ["id4"],
    numbers: ["id5", "id6", "id7", "id8"],
    crown: ["id12"],
    base: ["id3"],
    hand: ["id9", "id10", "id11"],
  }

  # Mapping from color name to svg color.
  # The order is the same as the shopping page.
  COLORS = [
    ["Dead White", "rgb(255,255,255)"],
    ["Moon Yellow", "rgb(255,255,53)"],
    ["Sun Yellow", "rgb(253, 204, 47)"],
    ["Gold Yellow", "rgb(248, 178, 42)"],
    ["Orange Gire", "rgb(231, 98, 45)"],
    ["Hot Orange", "rgb(216,32,37)"],
    ["Bloody Red", "rgb(185, 25, 38)"],
    ["Gory Red", "rgb(128, 16, 23)"],
    ["Scarlett Red", "rgb(115, 24, 42)"],
    ["Squid Pink", "rgb(218, 131, 176)"],
    ["Warlord Purple", "rgb(127, 23, 59)"],
    ["Hexed Lichen", "rgb(51, 41, 73)"],
    ["Royal Purple", "rgb(34, 42, 75)"],
    ["Dark Blue", "rgb(24, 38, 84)"],
    ["Stormy Blue", "rgb(21, 32, 74)"],
    ["Night Blue", "rgb(19, 32, 56)"],
    ["Imperial Blue", "rgb(17, 32, 66)"],
    ["Magic Blue", "rgb(6,64,121)"],
    ["Ultramarine Blue", "rgb(36, 49, 131)"],
    ["Electric Blue", "rgb(21, 140, 187)"],
    ["Turqoise", "rgb(10, 94, 95)"],
    ["Foul Green", "rgb(40, 138, 107)"],
    ["Jade Green", "rgb(16, 126, 108)"],
    ["Scurvy Green", "rgb(9, 71, 72)"],
    ["Dark Green", "rgb(10, 48, 38)"],
    ["Sick Green", "rgb(12, 93, 44)"],
    ["Goblin Green", "rgb(23, 107, 45)"],
    ["Camouflage Green", "rgb(112, 114, 48)"],
    ["Escorpena Green", "rgb(76,168,60)"],
    ["Livery Green", "rgb(171, 200, 91)"],
    ["Bonewhite", "rgb(234, 196, 137)"],
    ["Dead Flesh", "rgb(199, 188, 134)"],
    ["Bronze Fleshtone", "rgb(223, 156, 94)"],
    ["Filthy Brown", "rgb(239, 144, 42)"],
    ["Scrofulous Brown", "rgb(210, 126, 41)"],
    ["Plague Brown", "rgb(207, 155, 41)"],
    ["Leather Brown", "rgb(119, 82, 35)"],
    ["Dwarf Skin", "rgb(206, 123, 98)"],
    ["Parasite Brown", "rgb(177, 72, 32)"],
    ["Beasty Brown", "rgb(94, 73, 50)"],
    ["Dark Fleshtone", "rgb(83, 46, 41)"],
    ["Charred Brown", "rgb(63, 53, 58)"],
    ["Ghost Grey", "rgb(182, 203, 219)"],
    ["Wolf Grey", "rgb(164,177,195)"],
    ["Sombre Grey", "rgb(71, 91, 119)"],
    ["Stonewall Grey", "rgb(137, 146, 148)"],
    ["Cold Grey", "rgb(86, 100, 105)"],
    ["Black", "rgb(1, 6, 6)"],
    ["Silver", "rgb(144, 155, 157)"],
    ["Chainmal Silver", "rgb(112, 123, 124)"],
    ["Gunmetal", "rgb(72, 87, 85)"],
    ["Bright Bronze", "rgb(197, 158, 45)"],
    ["Brassy Brass", "rgb(109, 69, 39)"],
    ["Hammered Copper", "rgb(92, 44, 36)"],
    ["Tinny Tin", "rgb(60, 39, 36)"],
    ["Kakhi", "rgb(150, 134, 108)"],
    ["Earth", "rgb(116, 85, 58)"],
    ["Desert Yellow", "rgb(149, 124, 65)"],
    ["Yellow Olive", "rgb(6, 59, 46)"],
    ["Terracota", "rgb(111, 29, 23)"],
    ["Tan", "rgb(161, 69, 67)"],
    ["Cayman Green", "rgb(41, 85, 67)"],
    ["Smokey", "rgb(44,24,24)"],
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
      svg = `document.getElementById("clockcap")`
      AREAS[part_name].each do |svg_id|
        sel = "##{svg_id} path"
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
