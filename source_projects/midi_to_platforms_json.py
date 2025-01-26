from pathlib import Path
import mido
import json


"""
Midi am besten zischen c3 und c4
"""
def midi_to_platforms(midi_file):
    # Load the MIDI file
    midi = mido.MidiFile(midi_file)
    
    # Initialize the platforms list
    platforms = []
    ticks_per_beat = midi.ticks_per_beat  # Get ticks per beat for scaling time
    print(ticks_per_beat)
    time_offset = 0  # Keep track of elapsed time
    scale = 10
    # Process each track in the MIDI file
    for i, track in enumerate(midi.tracks):
        print(f"Processing track {i}: {track.name}")
        note_start_times = {}  # To track active notes and their start times
        
        for msg in track:
            # Accumulate elapsed time
            time_offset += msg.time
            
            # Handle note-on messages
            if msg.type == 'note_on' and msg.velocity > 0:
                note_pitch = msg.note
                if note_pitch not in note_start_times:
                    note_start_times[note_pitch] = time_offset  # Record start time

            # Handle note-off or note-on with velocity=0 messages
            elif (msg.type == 'note_off' or (msg.type == 'note_on' and msg.velocity == 0)):
                note_pitch = msg.note
                if note_pitch in note_start_times:
                    # Calculate duration between note_on and note_off
                    note_start = note_start_times.pop(note_pitch)
                    note_duration = time_offset - note_start

                    # Calculate platform properties
                    platform = {
                        "x": (note_start / ticks_per_beat) * scale,  # Scale start time to x position
                        "y": 127 - note_pitch,             # Height inversely related to pitch
                        "w": (note_duration / ticks_per_beat) * scale # Scale duration to width
                    }
                    platforms.append(platform)
    return platforms
    

# Example usage
midi_file= "levels/5/level5_basic_pitch.mid"
length_file= "levels/5/level5_basic_pitch_1.mid"  # Replace with your MIDI file path

output_file = f"levels/{Path(midi_file).name}.json"
plts = midi_to_platforms(midi_file)
length = midi_to_platforms(length_file)
out_data = {
    "total_length": length[0]["w"],
    "platforms": plts
}
# Save platforms as a JSON file
with open(output_file, 'w') as f:
    json.dump(out_data, f, indent=4)
print(f"Platforms saved to {output_file}")