import json

def render_platforms(json_file, output_file, width=2000, height=70):
    # Load platform data from JSON
    with open(json_file, 'r') as f:
        platforms = json.load(f)["platforms"]
    
    # Create a blank grid with `0`s
    grid = [[0 for _ in range(width)] for _ in range(height)]

    # Draw platforms onto the grid
    for platform in platforms:
        x_start = round(platform['x'])  # Round x to the nearest integer
        y = int(platform['y'])          # Use integer y
        w = round(platform['w'])        # Round w to the nearest integer

        if 0 <= y < height:
            for x in range(x_start, x_start + w):
                if 0 <= x < width:
                    grid[y][x] = 1

    # Write the grid to a text file
    with open(output_file, 'w') as f:
        for row in reversed(grid):  # Reverse to render top-down (higher y is lower on the grid)
            f.write(''.join(map(str, row)) + '\n')

    print(f"Rendered platforms saved to {output_file}")

# Example usage
json_file = "platforms.json"  # Replace with your JSON file path
output_file = "platforms_rendered.txt"
render_platforms(json_file, output_file)
