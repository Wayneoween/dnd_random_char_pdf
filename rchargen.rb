require "prawn"
require "prawn/measurement_extensions"
require 'ostruct'
require 'net/http'
require 'json'

url = 'http://npcgenerator.azurewebsites.net/_/npc'
uri = URI(url)
limit = 3

npcs = Array.new

limit.times do
  response = Net::HTTP.get(uri)
  npcs << JSON.parse(response, object_class: OpenStruct)
end

info = {
  :Title => "Randomly generated NPCs",
  :Author => "Foo Bar Baz",
  :Keywords => "NPC Dungeon Dragons",
  :Creator => "Me",
  :Producer => "Prawn",
  :CreationDate => Time.now
}

Prawn::Document.generate("random_characters.pdf",
                         :page_size => "A4",
                         :info => info,
                        ) do
  counter = 0
  x_position = 0
  y_position = cursor
  gap = 5
  npcs.each do |npc|
    alignment = npc.alignment.to_h.sort_by{ |a, v| v }.pop

    bounding_box([x_position, y_position], :width => 520) do
      transparent(1) { stroke_bounds }
      bounding_box([gap, cursor - gap], :width => 500) do
        # Character Name
        formatted_text [
          { :text => npc.description.name,
            :size => 16,
            :styles => [:bold]
        },
        { :text => "  ",
          :size => 12,
          :styles => [:bold]
        },
        { :text => "#{npc.description.gender.capitalize} #{npc.description.race.capitalize}; #{npc.description.occupation.capitalize}",
          :size => 12,
          :styles => [:bold]
        },
        ]
        # Alignment
        formatted_text [
          { :text => "#{alignment[0].capitalize}", :styles => [:bold] },
        ]
        move_down 8
        # Description
        formatted_text [
          { :text => "Description", :styles => [:bold] },
        ]
        move_down 2
        text "#{npc.description.pronounCapit}has #{npc.physical.face}."
        text "#{npc.description.pronounCapit}also has #{npc.physical.hair + npc.physical.eyes + " as well as " + npc.physical.skin}."
        text "#{npc.description.pronounCapit}stands #{npc.physical.height}cm tall and has #{npc.physical.build}."
        text "#{npc.physical.special1}"
        text "#{npc.religion.description}"
        move_down 4
        text "#{npc.description.pronounCapit}is #{npc.relationship.orientation.downcase} and #{npc.relationship.status.downcase}."
        move_down 6
        # Traits
        formatted_text [
          { :text => "Traits", :styles => [:bold] },
        ]
        move_down 2
        text "#{npc.ptraits.traits1}"
        text "#{npc.ptraits.traits2}"
      end
      # Dynamically draw the box height
      stroke_bounds
    end

    if counter > 1
      start_new_page
      counter = 0
    else
      move_down 30
      counter = counter + 1
    end
    y_position = cursor
  end

end
