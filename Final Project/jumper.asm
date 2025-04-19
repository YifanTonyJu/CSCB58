##############################################################################################################
#
# CSCB58 Winter 2025 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Yifan Ju, 1009920828, juyifan, yifan.ju@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# - Milestone 4 (All milestones completed)
#
# Which approved features have been implemented for milestone 4?
# 1. Disappearing platforms - Two platforms (6 and 10) disappear and reappear on a timer cycle
# 2. Pick-up effects - Three different power-ups with distinct effects:
#    - Blue power-up: Modifies water level to help player reach new areas
#    - Green power-up: Increases player score
#    - Purple power-up: Creates a bridge platform and removes obstacles
# 3. Start menu - Game has a start screen with flicker white strip means "Press any key to start"
# 4. Animated sprites - Power-ups are animated before being picked up by the player
#
# Link to video demonstration for final submission: https://drive.google.com/file/d/15X7RDcXHcWYIEcBi2_Nwzz7PFpyG-yJv/view?usp=share_link
#
# Are you OK with us sharing the video with people outside course staff?
# - no
#
# Any additional information that the TA needs to know:
# - Game controls: 'a' (move left), 'd' (move right), 'w' (jump), 'p' (restart game)
# - Player must collect items to increase score, use power-ups to unlock paths, and reach
#   the button at the top to complete the game
# - Falling into water results in game over
# - Some parts of the code are written for debugging and testing.
#
########################################################################################################






# Color constants definitions
.eqv    DEEP_WATER_CLR 0x1976d2   # Deep water color (dark blue)
.eqv    SHALLOW_WATER_CLR 0x64b5f6 # Shallow water color (light blue)
.eqv    NAVY_CLR 0x1a237e         # Navy color (very dark blue)
.eqv    PLATFORM_SHADE 0x607d8b    # Platform shade color (gray-blue)
.eqv	DISPLAY_BASE 0x10008000    # Base memory address for display
.eqv	VOID_CLR 0x000000          # Void/background color (black)
.eqv	TERRAIN_CLR 0x4caf50       # Terrain color (green)
.eqv	BRIGHT_CLR 0xffffff        # Bright color (white)
.eqv 	OCEAN_CLR 0x2195f3         # Ocean color (blue)
.eqv	BTN_NEUTRAL 0x9e9e9e       # Neutral button color (gray)
.eqv	BTN_DANGER 0xff1745        # Danger button color (red)
.eqv	OBSTACLE_CLR 0x4e342e      # Obstacle color (brown)
.eqv 	SUCCESS_CLR 0x17d421       # Success color (green)
.eqv	FAILURE_CLR	0xe91e62       # Failure color (pink)

# Power-up colors
.eqv	POWER1_BASE 0x2195f3       # Power 1 base color (blue)
.eqv	POWER1_HIGHLIGHT 0x40c3ff  # Power 1 highlight color (light blue)
.eqv	POWER2_BASE 0x4caf4f       # Power 2 base color (green)
.eqv 	POWER2_HIGHLIGHT 0x8bc34a  # Power 2 highlight color (light green)
.eqv 	POWER3_BASE 0x661fff       # Power 3 base color (purple)
.eqv	POWER3_HIGHLIGHT 0xb488ff  # Power 3 highlight color (light purple)

# Collectible item colors
.eqv	TREASURE_PRIMARY 0xffc107  # Treasure primary color (yellow/gold)
.eqv	TREASURE_SECONDARY 0x40a4f5 # Treasure secondary color (blue)

# Character colors
.eqv	CHAR_HEAD 0xf5f5f5         # Character head color (off-white)
.eqv	CHAR_EYE1 0xa1887f         # Character eye color 1 (brown)
.eqv	CHAR_EYE2 0xd50000         # Character eye color 2 (red)
.eqv	CHAR_SKIN 0xfce8db         # Character skin color (light peach)
		
# Game constants
.eqv	UI_LEVEL 56                # UI level (display line)
.eqv 	WATER_LEVEL1 55            # First water level (display line)
.eqv	WATER_LEVEL2 54            # Second water level (display line)
.eqv	FRAME_DELAY 50             # Delay between frames (milliseconds)
.eqv 	JUMP_HEIGHT_MAX 12         # Maximum jump height

# Game data structures
.data
EntityData: 	.word 	2, 46, -1, -1, 1, 1, 1 	# Player and entity data storage
WorldData: 	.word 	2, 46, 0, 0, 60, 36, 60, 36, 29, 13, 29, 13 # World state storage

.text

# Main setup function to initialize the game
setup:
    li $s0, 0       # Initialize score counter to 0
    li $s1, 2       # Initialize player x position
    li $s2, 46      # Initialize player y position
    la $s3, EntityData   # Load EntityData address to $s3
    la $s4, WorldData    # Load WorldData address to $s4
    li $s5, 0       # Initialize jump counter
    li $s6, 0       # Initialize jump state flag
    li $s7, 0       # Initialize player movement flag
    li $t0, DISPLAY_BASE  # Load display base address
    
    jal resetDisplay      # Reset the display to blank state
    li $t9, 55      # Set maximum counter for intro background
    li $t7, 0       # Initialize loop counter
    
# Draw intro background - green gradient
intro_background:
    bgt $t7, $t9, intro_background_complete # If counter > max, exit loop
    li $a0, SUCCESS_CLR     # Load green color
    li $a1, 0               # Start x-coordinate
    li $a2, 63              # End x-coordinate
    move $a3, $t7           # Current y-coordinate
    jal renderHLine         # Draw horizontal line
    addi $t7, $t7, 1        # Increment counter
    j intro_background      # Loop
    
# Intro background drawing completed
intro_background_complete:
    # Draw game title/logo with gold color blocks
    li $a0, TREASURE_PRIMARY  # Load gold color
    li $a1, 20 # Start x position
    li $a2, 20 # End x position
    li $a3, 20 # Y position
    jal renderHLine # Draw horizontal line
    li $a3, 21 # Next Y position
    jal renderHLine # Draw another line
    li $a3, 22 # Next Y position
    jal renderHLine # Draw another line
    li $a3, 23 # Next Y position
    jal renderHLine # Draw another line
    
    # Draw part of the letter
    li $a1, 18 # Start x position
    li $a2, 20 # End x position
    li $a3, 24 # Y position
    jal renderHLine # Draw horizontal line
    
    # Draw another part of the letter
    li $a1, 22  # Start x position
    li $a2, 22  # End x position
    li $a3, 20  # Y position
    jal renderHLine # Draw horizontal line
    li $a3, 21  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 22  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 23  # Next Y position
    jal renderHLine # Draw another line
    
    # Draw connector
    li $a1, 22  # Start x position
    li $a2, 26  # End x position
    li $a3, 24  # Y position
    jal renderHLine # Draw horizontal line
    
    # Draw next block
    li $a1, 26  # Start x position
    li $a2, 26  # End x position
    li $a3, 20  # Y position
    jal renderHLine # Draw horizontal line
    li $a3, 21  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 22  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 23  # Next Y position
    jal renderHLine # Draw another line
    
    # Draw another block
    li $a1, 28  # Start x position
    li $a2, 28  # End x position
    li $a3, 20  # Y position
    jal renderHLine # Draw horizontal line
    li $a3, 21  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 22  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 23  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 24  # Next Y position
    jal renderHLine # Draw another line
    
    # Draw more parts of the title
    li $a1, 29  # Start x position
    li $a2, 29  # End x position
    li $a3, 21  # Y position
    jal renderHLine # Draw horizontal line
    
    li $a1, 30  # Start x position
    li $a2, 30  # End x position
    li $a3, 22  # Y position
    jal renderHLine # Draw horizontal line
    
    li $a1, 31  # Start x position
    li $a2, 31  # End x position
    li $a3, 21  # Y position
    jal renderHLine # Draw horizontal line
    
    # Continue drawing title elements
    li $a1, 32  # Start x position
    li $a2, 32  # End x position
    li $a3, 20  # Y position
    jal renderHLine # Draw horizontal line
    li $a3, 21  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 22  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 23  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 24  # Next Y position
    jal renderHLine # Draw another line
    
    # Draw more title elements
    li $a1, 34  # Start x position
    li $a2, 34  # End x position
    li $a3, 20  # Y position
    jal renderHLine # Draw horizontal line
    li $a3, 21  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 22  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 23  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 24  # Next Y position
    jal renderHLine # Draw another line
    
    # Draw horizontal connector
    li $a1, 34  # Start x position
    li $a2, 37  # End x position
    li $a3, 20  # Y position
    jal renderHLine # Draw horizontal line
    
    # Draw middle connector
    li $a1, 34  # Start x position
    li $a2, 37  # End x position
    li $a3, 22  # Y position
    jal renderHLine # Draw horizontal line
    
    # Draw vertical part
    li $a1, 37  # Start x position
    li $a2, 37  # End x position
    li $a3, 20  # Y position
    jal renderHLine # Draw horizontal line
    li $a3, 21  # Next Y position
    jal renderHLine # Draw another line
    
    # Draw next letter
    li $a1, 39  # Start x position
    li $a2, 39  # End x position
    li $a3, 20  # Y position
    jal renderHLine # Draw horizontal line
    li $a3, 21  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 22  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 23  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 24  # Next Y position
    jal renderHLine # Draw another line
    
    # Draw horizontal connectors
    li $a1, 39  # Start x position
    li $a2, 42  # End x position
    li $a3, 20  # Y position
    jal renderHLine # Draw horizontal line
    
    li $a1, 39  # Start x position
    li $a2, 41  # End x position
    li $a3, 22  # Y position
    jal renderHLine # Draw horizontal line
    
    li $a1, 39  # Start x position
    li $a2, 42  # End x position
    li $a3, 24  # Y position
    jal renderHLine # Draw horizontal line
    
    # Draw final letter
    li $a1, 44  # Start x position
    li $a2, 44  # End x position
    li $a3, 20  # Y position
    jal renderHLine # Draw horizontal line
    li $a3, 21  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 22  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 23  # Next Y position
    jal renderHLine # Draw another line
    li $a3, 24  # Next Y position
    jal renderHLine # Draw another line
    
    # Draw horizontal connectors for final letter
    li $a1, 44  # Start x position
    li $a2, 47  # End x position
    li $a3, 20  # Y position
    jal renderHLine # Draw horizontal line
    
    li $a1, 44  # Start x position
    li $a2, 47  # End x position
    li $a3, 22  # Y position
    jal renderHLine # Draw horizontal line
    
    # Draw right side of final letter
    li $a1, 47  # Start x position
    li $a2, 47  # End x position
    li $a3, 20  # Y position
    jal renderHLine # Draw horizontal line
    li $a3, 21  # Next Y position
    jal renderHLine # Draw another line
    
    # Draw bottom details of final letter
    li $a1, 45  # Start x position
    li $a2, 45  # End x position
    li $a3, 23  # Y position
    jal renderHLine # Draw horizontal line
    
    li $a1, 46  # Start x position
    li $a2, 46  # End x position
    li $a3, 24  # Y position
    jal renderHLine # Draw horizontal line

    li $t5, 0  # Initialize animation counter

# Title animation - flashing "Press any key to start" text
title_animation:
    li $t9, 0xffff0000  # Address for keyboard input
    lw $t8, 0($t9)      # Load keyboard status
    beq $t8, 1, begin_game # If key pressed, go to begin_game

    # Draw "Press any key" message in white
    li $a0, BRIGHT_CLR # White color
    li $a1, 24 # Start x position
    li $a2, 40 # End x position
    li $a3, 36 # Y position
    jal renderHLine # Draw horizontal line
    
    # Wait for 300ms
    li $v0, 32 # Syscall for sleep
    li $a0, 300 # 300 milliseconds
    syscall
    
    # Check if key pressed during wait
    li $t9, 0xffff0000 # Address for keyboard input
    lw $t8, 0($t9) # Load keyboard status
    beq $t8, 1, begin_game # If key pressed, go to begin_game
    
    # Draw "Press any key" message in green
    li $a0, SUCCESS_CLR # Green color
    li $a1, 24 # Start x position
    li $a2, 40 # End x position
    li $a3, 36 # Y position
    jal renderHLine # Draw horizontal line
    
    # Wait for 300ms
    li $v0, 32 # Syscall for sleep
    li $a0, 300 # 300 milliseconds
    syscall

    # Loop for continuous animation
    j title_animation

# Start the game
begin_game:
    lw $t2, 4($t9)       # Load pressed key value
    jal resetDisplay     # Clear the screen
    jal renderInitialWorld # Draw the initial game world
    j game_loop          # Jump to main game loop

# Main game loop
game_loop:
	li $s7, 1		# Set player movement flag to 1
	sw $s1, 0($s3)		# Store player x position in EntityData
	sw $s2, 4($s3)		# Store player y position in EntityData
	lw $t1, 16($s4)		# Load powerup 1 x position
	lw $t2, 20($s4)		# Load powerup 1 y position
	sw $t1, 24($s4)		# Store current x position as previous
	sw $t2, 28($s4)		# Store current y position as previous
	lw $t1, 32($s4)		# Load powerup 2 x position
	lw $t2, 36($s4)		# Load powerup 2 y position
	sw $t1, 40($s4)		# Store current x position as previous
	sw $t2, 44($s4)		# Store current y position as previous
	lw $t1, 8($s3)		# Load platform 6 timer
	addi $t1, $t1, 1	# Increment platform 6 timer
	sw $t1, 8($s3)		# Store updated platform 6 timer
	lw $t1, 12($s3)		# Load platform 10 timer
	addi $t1, $t1, 1	# Increment platform 10 timer
	sw $t1, 12($s3)		# Store updated platform 10 timer
	
	# Check if player is jumping
	beq $s6, $zero, apply_gravity	# If not jumping, apply gravity
	j continue_jump		# If jumping, continue the jump
				
# Process the game state after physics updates
process_game_state:
check_platform6:
	lw $t1, 8($s3)		# Load platform 6 timer
	beqz $t1, render_platform6	# If timer is 0, render platform
	li $t2, 20		# Platform 6 visible duration
	beq $t1, $t2, clear_platform6	# If timer at visible duration, clear platform
	li $t2, 40		# Platform 6 cycle duration
	beq $t1, $t2, cycle_platform6	# If timer at cycle duration, reset cycle
check_platform10:
	lw $t1, 12($s3)		# Load platform 10 timer
	beqz $t1, render_platform10	# If timer is 0, render platform
	li $t2, 20		# Platform 10 visible duration
	beq $t1, $t2, clear_platform10	# If timer at visible duration, clear platform
	li $t2, 40		# Platform 10 cycle duration
	beq $t1, $t2, cycle_platform10	# If timer at cycle duration, reset cycle
	
skip_platform_updates:
	li $t9, 0xffff0000	# Address for keyboard input
	lw $t8, 0($t9)		# Load keyboard status
	beq $t8, 1, process_input	# If key pressed, process input
		
continue_game_loop:
check_item1:
	li $t1, TREASURE_SECONDARY	# Load treasure secondary color
	lw $t2, 10808($t0)	# Load color at item 1 position
	bne $t2, TREASURE_SECONDARY, check_item2	# If not treasure, check next item
	li $a0, 9		# Item 1 x position
	li $a2, 38         # Item 1 y position
	jal check_collision_item	# Check if player collided with item
check_item2:
	li $t1, TREASURE_SECONDARY	# Load treasure secondary color
	lw $t2, 7060($t0)	# Load color at item 2 position
	bne $t2, TREASURE_SECONDARY, check_item3	# If not treasure, check next item
	li $a0, 32		# Item 2 x position
	li $a2, 23         # Item 2 y position
	jal check_collision_item	# Check if player collided with item
check_item3:
	li $t1, VOID_CLR	# Load void color
	lw $t2, 1980($t0)	# Load color at item 3 position
	bne $t2, TREASURE_SECONDARY, skip_item_checks	# If not treasure, skip item checks
	li $a0, 42		# Item 3 x position
	li $a2, 3          # Item 3 y position
	jal check_collision_item	# Check if player collided with item
	
skip_item_checks:
check_powerup1:
	lw $t1, 16($s3)		# Load powerup 1 state
	beqz $t1, check_powerup2	# If powerup inactive, check next powerup
	jal check_pickup_blue # Check if player picked up blue powerup

check_powerup2:
	lw $t1, 20($s3)		# Load powerup 2 state
	beqz $t1, check_powerup3	# If powerup inactive, check next powerup
	jal check_pickup_green # Check if player picked up green powerup
	
check_powerup3:
	lw $t1, 24($s3)		# Load powerup 3 state
	beqz $t1, skip_powerup_checks	# If powerup inactive, skip powerup checks
	jal check_pickup_violet # Check if player picked up violet powerup
	
skip_powerup_checks:
check_blue_fx:
	lw $t1, 16($s3)		# Load blue powerup state
	beqz $t1, check_green_fx # If blue powerup inactive, check green powerup
	jal animate_blue # Animate blue powerup
check_green_fx:
	lw $t1, 20($s3)		# Load green powerup state
	beqz $t1, update_player # If green powerup inactive, update player
	jal animate_green # Animate green powerup
	
skip_effects:

update_player:
	li $t5, 1		# Set flag value
	beq $s7, $t5, skip_player_update	# If player hasn't moved, skip update
	# Update player graphics
	lw $a1, 0($s3)		# Load old player x position
	lw $a3, 4($s3)		# Load old player y position
	jal remove_player	# Remove player from old position
	move $a1, $s1		# Set new x position
	move $a3, $s2		# Set new y position
	jal draw_player		# Draw player at new position
	
skip_player_update:
	# Pause for frame timing
	li $v0, 32		# Syscall for sleep
	li $a0, FRAME_DELAY 	# Load frame delay time
	syscall
	j game_loop		# Loop back to the start of game loop

# Victory screen
victory_screen:
	jal clear_game_area	# Clear the game area
	li $a0, SUCCESS_CLR	# Load success color (green)
	jal draw_restart_prompt	# Draw the restart prompt
	jal draw_victory_title_part1	# Draw first part of victory title
	jal draw_victory_title_part2	# Draw second part of victory title
	j wait_for_restart  # Jump to restart waiting loop
	
# Defeat screen
defeat_screen:
	jal clear_game_area	# Clear the game area
	li $a0, FAILURE_CLR	# Load failure color (red)
	jal draw_restart_prompt	# Draw the restart prompt
	jal draw_defeat_title_part1	# Draw first part of defeat title
	jal draw_defeat_title_part2	# Draw second part of defeat title
	j wait_for_restart  # Jump to restart waiting loop

# Wait for key press to restart game
wait_for_restart:
	li $t9, 0xffff0000	# Address for keyboard input
	lw $t8, 0($t9)		# Load keyboard status
	bne $t8, 1, wait_for_restart	# If no key pressed, keep waiting
	lw $t2, 4($t9) 		# Load pressed key value
	beq $t2, 0x70, restart_game	# If 'p' pressed, restart game
	j wait_for_restart  # Otherwise keep waiting

	# Return to caller (debugging)
	lw $ra, 0($sp)		# Load return address from stack
	addi $sp, $sp, 4	# Adjust stack pointer
	jr $ra             # Return

# Render platform 6 (make it visible)
render_platform6:
	li $a0, TERRAIN_CLR	# Load terrain color
	li $a1, 47		# Start x position
	li $a2, 53		# End x position
	li $a3, 33 		# Y position
	jal renderHLine     # Draw the platform
	j check_platform10  # Check platform 10 next
# Clear platform 6 (make it invisible)
clear_platform6:
	li $a0, VOID_CLR	# Load void/background color
	li $a1, 47		# Start x position
	li $a2, 53		# End x position
	li $a3, 33 		# Y position
	jal renderHLine     # Erase the platform
	j check_platform10  # Check platform 10 next
# Reset platform 6 cycle
cycle_platform6:
	li $a0, TERRAIN_CLR	# Load terrain color
	li $a1, 47		# Start x position
	li $a2, 53		# End x position
	li $a3, 33 		# Y position
	jal renderHLine     # Draw the platform
	sw $zero, 8($s3)	# Reset platform 6 timer
	j check_platform10  # Check platform 10 next

# Render platform 10 (make it visible)
render_platform10:
	li $a0, TERRAIN_CLR	# Load terrain color
	li $a1, 10		# Start x position
	li $a2, 16		# End x position
	li $a3, 17 		# Y position
	jal renderHLine     # Draw the platform
	j skip_platform_updates # Skip to the next section
# Clear platform 10 (make it invisible)
clear_platform10:
	li $a0, VOID_CLR	# Load void/background color
	li $a1, 10		# Start x position
	li $a2, 16		# End x position
	li $a3, 17 		# Y position
	jal renderHLine     # Erase the platform
	j skip_platform_updates # Skip to the next section
# Reset platform 10 cycle
cycle_platform10:
	li $a0, TERRAIN_CLR	# Load terrain color
	li $a1, 10		# Start x position
	li $a2, 16		# End x position
	li $a3, 17 		# Y position
	jal renderHLine     # Draw the platform
	sw $zero, 12($s3)	# Reset platform 10 timer
	j skip_platform_updates # Skip to the next section

# Animate blue powerup
animate_blue:
	li $t2, 1          # Constant for upward animation
	lw $t1, 16($s3)	   # Load blue powerup state
	beq $t1, $t2, animate_blue_up # If state is 1, animate upward
	# Animate downward
	lw $t2, 20($s4)	   # Load blue powerup y position
	addi $t2, $t2, 1   # Increment y position (move down)
	sw $t2, 20($s4)	   # Store updated y position
	
	li $t3, 36		   # Bottom boundary
	beq $t2, $t3, set_blue_mode_up # If at bottom, change to upward mode
	j update_blue_fx   # Update the blue effect
	
# Animate blue powerup upward
animate_blue_up:
	lw $t2, 20($s4)	   # Load blue powerup y position
	addi $t2, $t2, -1  # Decrement y position (move up)
	sw $t2, 20($s4)	   # Store updated y position
	
	li $t3, 33		   # Top boundary
	beq $t2, $t3, set_blue_mode_down # If at top, change to downward mode
	j update_blue_fx   # Update the blue effect

# Set blue powerup animation to upward mode
set_blue_mode_up:
	li $t5, 1		   # Mode 1 = upward
	sw $t5, 16($s3)	   # Store mode
	j update_blue_fx   # Update the blue effect

# Set blue powerup animation to downward mode
set_blue_mode_down:
	li $t5, 2		   # Mode 2 = downward
	sw $t5, 16($s3)	   # Store mode
	j update_blue_fx   # Update the blue effect
	
# Update blue powerup visuals
update_blue_fx:
	li $a0, POWER1_BASE # Load blue powerup base color
	jal remove_powerup  # Remove old powerup
	li $a0, POWER1_BASE # Load blue powerup base color
	lw $t1, 16($s4)	   # Load blue powerup x position
	lw $t2, 20($s4)	   # Load blue powerup y position
	move $a1, $t1	   # Set x position
	addi $a2, $t1, 2   # Set width
	move $a3, $t2	   # Set y position
	jal draw_powerup   # Draw the powerup
	j check_green_fx   # Check green powerup next
	
# Animate green powerup
animate_green:
	li $t2, 1          # Constant for upward animation
	lw $t1, 20($s3)	   # Load green powerup state
	beq $t1, $t2, animate_green_up # If state is 1, animate upward
	# Animate downward
	lw $t2, 36($s4)	   # Load green powerup y position
	addi $t2, $t2, 1   # Increment y position (move down)
	sw $t2, 36($s4)	   # Store updated y position
	
	li $t3, 13		   # Bottom boundary
	beq $t2, $t3, set_green_mode_up # If at bottom, change to upward mode
	j update_green_fx  # Update the green effect

# Animate green powerup upward
animate_green_up:
	lw $t2, 36($s4)	   # Load green powerup y position
	addi $t2, $t2, -1  # Decrement y position (move up)
	sw $t2, 36($s4)	   # Store updated y position
	
	li $t3, 10		   # Top boundary
	beq $t2, $t3, set_green_mode_down # If at top, change to downward mode
	j update_green_fx  # Update the green effect

# Set green powerup animation to upward mode
set_green_mode_up:
	li $t5, 1		   # Mode 1 = upward
	sw $t5, 20($s3)	   # Store mode
	j update_green_fx  # Update the green effect

# Set green powerup animation to downward mode
set_green_mode_down:
	li $t5, 2		   # Mode 2 = downward
	sw $t5, 20($s3)	   # Store mode
	j update_green_fx  # Update the green effect

# Update green powerup visuals
update_green_fx:
	li $a0, POWER2_BASE # Load green powerup base color
	jal remove_powerup  # Remove old powerup
	li $a0, POWER2_BASE # Load green powerup base color
	lw $t1, 32($s4)	   # Load green powerup x position
	lw $t2, 36($s4)	   # Load green powerup y position
	move $a1, $t1	   # Set x position
	addi $a2, $t1, 2   # Set width
	move $a3, $t2	   # Set y position
	jal draw_powerup   # Draw the powerup
	j skip_effects	   # Skip to next section
	
# Check if player picked up blue powerup
check_pickup_blue:
	li $t1, 58		   # Blue powerup region x min
	li $t2, 63		   # Blue powerup region x max
	li $t3, 31		   # Blue powerup region y min
	li $t4, 39		   # Blue powerup region y max
	bge $s1, $t1, blue_test_x_max	# If player x >= region min, continue check
	jr $ra               # Return if player not in region
blue_test_x_max:
	ble $s1, $t2, blue_test_y_min	# If player x <= region max, continue check
	jr $ra               # Return if player not in region
blue_test_y_min:
	bge $s2, $t3, blue_test_y_max	# If player y >= region min, continue check
	jr $ra               # Return if player not in region
blue_test_y_max:
	ble $s2, $t4, activate_blue_powerup	# If player y <= region max, activate powerup
	jr $ra               # Return if player not in region

# Activate blue powerup effect (modify water level)
activate_blue_powerup:
	li $a0, TERRAIN_CLR	# Load terrain color
	li $a3, WATER_LEVEL1	# First water level y position
	li $a1, 0		   # Start x position
	li $a2, 63		   # End x position
	jal renderHLine    # Draw horizontal line (fill water with terrain)
	
	li $a0, TERRAIN_CLR	# Load terrain color
	li $a3, WATER_LEVEL2	# Second water level y position
	li $a1, 0		   # Start x position
	li $a2, 63		   # End x position
	jal renderHLine    # Draw horizontal line (fill water with terrain)
	
	# Fill additional water level
	li $a0, TERRAIN_CLR
    li $a3, WATER_LEVEL2
    addi $a3, $a3, -1  # One level above water level 2
    li $a1, 0          # Start x position
    li $a2, 63         # End x position
    jal renderHLine    # Draw horizontal line
	
	# Remove blue powerup
	li $a0, POWER1_BASE	# Load blue powerup base color
	jal remove_powerup  # Remove powerup
	sw $zero, 16($s3)	# Deactivate blue powerup state
	j skip_powerup_checks	# Skip other powerup checks
	
# Check if player picked up green powerup
check_pickup_green:
	li $t1, 26		   # Green powerup region x min
	li $t2, 34		   # Green powerup region x max
	li $t3, 8		   # Green powerup region y min
	li $t4, 16		   # Green powerup region y max
	bge $s1, $t1, green_test_x_max	# If player x >= region min, continue check
	jr $ra             # Return if player not in region
green_test_x_max:
	ble $s1, $t2, green_test_y_min	# If player x <= region max, continue check
	jr $ra             # Return if player not in region
green_test_y_min:
	bge $s2, $t3, green_test_y_max	# If player y >= region min, continue check
	jr $ra             # Return if player not in region
green_test_y_max:
	ble $s2, $t4, activate_green_powerup	# If player y <= region max, activate powerup
	jr $ra             # Return if player not in region

# Activate green powerup effect (increase score)
activate_green_powerup:
	addi $s0, $s0, 3	# Increase score by 3
	jal update_score_display # Update score display
	li $a0, POWER2_BASE	# Load green powerup base color
	jal remove_powerup  # Remove powerup
	sw $zero, 20($s3)	# Deactivate green powerup state
	j skip_powerup_checks	# Skip other powerup checks
	
# Check if player picked up violet powerup
check_pickup_violet:
	li $t1, 58		   # Violet powerup region x min
	li $t2, 63		   # Violet powerup region x max
	li $t3, 0		   # Violet powerup region y min
	li $t4, 5		   # Violet powerup region y max
	bge $s1, $t1, violet_test_x_max	# If player x >= region min, continue check
	jr $ra             # Return if player not in region
violet_test_x_max:
	ble $s1, $t2, violet_test_y_min	# If player x <= region max, continue check
	jr $ra             # Return if player not in region
violet_test_y_min:
	bge $s2, $t3, violet_test_y_max	# If player y >= region min, continue check
	jr $ra             # Return if player not in region
violet_test_y_max:
	ble $s2, $t4, activate_violet_powerup	# If player y <= region max, activate powerup
	jr $ra             # Return if player not in region

# Activate violet powerup effect (create a platform bridge)
activate_violet_powerup:
	# Clear obstacles in the path
	li $a0, VOID_CLR	# Load void/background color
	sw $a0, 36($t0)	   # Clear obstacle pixel 1
	sw $a0, 292($t0)   # Clear obstacle pixel 2
	sw $a0, 548($t0)   # Clear obstacle pixel 3
	sw $a0, 804($t0)   # Clear obstacle pixel 4
	sw $a0, 1060($t0)  # Clear obstacle pixel 5
	sw $a0, 1316($t0)  # Clear obstacle pixel 6
	
	# Create bridge platform
	li $a0, TERRAIN_CLR	# Load terrain color
	li $a1, 10		   # Start x position
	li $a2, 58		   # End x position
	li $a3, 6		   # Y position
	jal renderHLine    # Draw horizontal platform bridge
	
	# Remove violet powerup
	li $a0, POWER3_BASE	# Load violet powerup base color
	jal remove_powerup  # Remove powerup
	sw $zero, 24($s3)	# Deactivate violet powerup state
	j skip_powerup_checks	# Skip other powerup checks

# Remove powerup visual based on type
remove_powerup:
	addi $sp, $sp, -4	# Adjust stack pointer
	sw $ra, 0($sp)		# Store return address
	
	beq $a0, POWER1_BASE, remove_powerup_blue	# If blue powerup, remove blue
	beq $a0, POWER2_BASE, remove_powerup_green  # If green powerup, remove green
remove_powerup_violet:
	li $a1, 60		   # Violet powerup x position
	li $a2, 62		   # Violet powerup width
	li $a3, 2		   # Violet powerup y position
	li $a0, VOID_CLR	# Load void/background color
	jal renderHLine    # Erase first row
	addi $a3, $a3, 1	# Move to next row
	jal renderHLine    # Erase second row
	addi $a3, $a3, 1	# Move to next row
	jal renderHLine    # Erase third row
	j remove_powerup_done # Finish removal
remove_powerup_blue:
	lw $a1, 24($s4)	   # Load blue powerup x position
	addi $a2, $a1, 2	# Calculate width
	lw $a3, 28($s4)	   # Load blue powerup y position
	li $a0, VOID_CLR	# Load void/background color
	jal renderHLine    # Erase first row
	addi $a3, $a3, 1	# Move to next row
	jal renderHLine    # Erase second row
	addi $a3, $a3, 1	# Move to next row
	jal renderHLine    # Erase third row
	j remove_powerup_done # Finish removal
remove_powerup_green:
	lw $a1, 40($s4)	   # Load green powerup x position
	addi $a2, $a1, 2	# Calculate width
	lw $a3, 44($s4)	   # Load green powerup y position
	li $a0, VOID_CLR	# Load void/background color
	jal renderHLine    # Erase first row
	addi $a3, $a3, 1	# Move to next row
	jal renderHLine    # Erase second row
	addi $a3, $a3, 1	# Move to next row
	jal renderHLine    # Erase third row
	j remove_powerup_done # Finish removal

remove_powerup_done:
	lw $ra, 0($sp)		# Load return address
	addi $sp, $sp, 4	# Adjust stack pointer
	jr $ra	            # Return
	
# Test for collision below the player
test_collision_below:
	move $t1, $a1		# Color to test for
	move $t2, $a2		# Player x position
	addi $t3, $a3, 3	# Player y position + 3 (below feet)
	
	sll $t4, $t3, 8		# Convert y to memory offset (y * 256)
	sll $t2, $t2, 2		# Convert x to memory offset (x * 4)
	add $t5, $t4, $t2	# Calculate total offset
	add $t6, $t0, $t5	# Calculate memory address
	lw $t7, ($t6)		# Load color at position
	beq $t7, $t1, collision_below_true	# If color matches, collision detected
	addi $t5, $t5, 4	# Move to next x position
	add $t6, $t0, $t5	# Calculate memory address
	lw $t7, 0($t6)		# Load color at position
	beq $t7, $t1, collision_below_true	# If color matches, collision detected
	addi $t5, $t5, 4	# Move to next x position
	add $t6, $t0, $t5	# Calculate memory address
	lw $t7, 0($t6)		# Load color at position
	beq $t7, $t1, collision_below_true	# If color matches, collision detected
	jr $ra			    # Return if no collision
collision_below_true:
	li $v0, 1		    # Set return value to 1 (collision)
	jr $ra			    # Return
	
# Test for collision above the player
test_collision_above:
	move $t1, $a1		# Color to test for
	move $t2, $a2		# Player x position
	addi $t3, $a3, -1	# Player y position - 1 (above head)
	
	sll $t4, $t3, 8		# Convert y to memory offset (y * 256)
	sll $t2, $t2, 2		# Convert x to memory offset (x * 4)
	add $t5, $t4, $t2	# Calculate total offset
	add $t6, $t0, $t5	# Calculate memory address
	lw $t7, ($t6)		# Load color at position
	beq $t7, $t1, collision_above_true	# If color matches, collision detected
	addi $t5, $t5, 4	# Move to next x position
	add $t6, $t0, $t5	# Calculate memory address
	lw $t7, 0($t6)		# Load color at position
	beq $t7, $t1, collision_above_true	# If color matches, collision detected
	addi $t5, $t5, 4	# Move to next x position
	add $t6, $t0, $t5	# Calculate memory address
	lw $t7, 0($t6)		# Load color at position
	beq $t7, $t1, collision_above_true	# If color matches, collision detected
	jr $ra			    # Return if no collision
collision_above_true:
	li $v0, 1		    # Set return value to 1 (collision)
	jr $ra			    # Return
	
# Test for collision to the left of the player
test_collision_left:
	move $t1, $a1		# Color to test for
	addi $t2, $a2, -1	# Player x position - 1 (left side)
	move $t3, $a3		# Player y position
							
	sll $t4, $t3, 8		# Convert y to memory offset (y * 256)
	sll $t2, $t2, 2		# Convert x to memory offset (x * 4)
	add $t5, $t4, $t2	# Calculate total offset
	add $t6, $t0, $t5	# Calculate memory address
	lw $t7, ($t6)		# Load color at position
	beq $t7, $t1, collision_left_true	# If color matches, collision detected
	addi $t5, $t5, 256	# Move to next y position
	add $t6, $t0, $t5	# Calculate memory address
	lw $t7, 0($t6)		# Load color at position
	beq $t7, $t1, collision_left_true	# If color matches, collision detected
	addi $t5, $t5, 256	# Move to next y position
	add $t6, $t0, $t5	# Calculate memory address
	lw $t7, 0($t6)		# Load color at position
	beq $t7, $t1, collision_above_true	# If color matches, collision detected
	jr $ra			    # Return if no collision
collision_left_true:
	li $v0, 1		    # Set return value to 1 (collision)
	jr $ra              # Return

# Test for collision to the right of the player
test_collision_right:
	move $t1, $a1		# Color to test for
	addi $t2, $a2, 3	# Player x position + 3 (right side)
	move $t3, $a3		# Player y position
							
	sll $t4, $t3, 8		# Convert y to memory offset (y * 256)
	sll $t2, $t2, 2		# Convert x to memory offset (x * 4)
	add $t5, $t4, $t2	# Calculate total offset
	add $t6, $t0, $t5	# Calculate memory address
	lw $t7, ($t6)		# Load color at position
	beq $t7, $t1, collision_right_true	# If color matches, collision detected
	addi $t5, $t5, 256	# Move to next y position
	add $t6, $t0, $t5	# Calculate memory address
	lw $t7, 0($t6)		# Load color at position
	beq $t7, $t1, collision_right_true	# If color matches, collision detected
	addi $t5, $t5, 256	# Move to next y position
	add $t6, $t0, $t5	# Calculate memory address
	lw $t7, 0($t6)		# Load color at position
	beq $t7, $t1, collision_right_true	# If color matches, collision detected
	jr $ra			    # Return if no collision
collision_right_true:
	li $v0, 1		    # Set return value to 1 (collision)
	jr $ra              # Return
	
# Process keyboard input
process_input:
	lw $t2, 4($t9) 		# Load pressed key value
	beq $t2, 0x61, move_player_left	# If 'a' pressed, move left
	beq $t2, 0x64, move_player_right	# If 'd' pressed, move right
	beq $t2, 0x77, attempt_player_jump	# If 'w' pressed, attempt jump
	beq $t2, 0x70, restart_game	      # If 'p' pressed, restart game
	j continue_game_loop # Continue game loop if other key pressed
	
# Attempt to make the player jump
attempt_player_jump:
	li $a1, TERRAIN_CLR	# Load terrain color
	move $a2, $s1		# Player x position
	move $a3, $s2		# Player y position
	jal test_collision_below # Test if player is on ground
	bgtz $v0, start_jump	# If on ground, start jump
	j continue_game_loop	# Continue game loop if not on ground
		
# Move player left
move_player_left:
	li $t5, 0		    # Left screen boundary
	li $v0, 0		    # Reset collision flag
	ble $s1, $t5, continue_game_loop	# If at left boundary, skip movement
	
	# Test for collisions with different obstacles
	li $a1, TERRAIN_CLR	# Test for terrain collision
	move $a2, $s1		# Player x position
	move $a3, $s2		# Player y position
	jal test_collision_left # Check for collision
	li $a1, OBSTACLE_CLR # Test for obstacle collision
	move $a2, $s1		# Player x position
	move $a3, $s2		# Player y position
	jal test_collision_left # Check for collision
	li $a1, BTN_NEUTRAL	# Test for neutral button collision
	move $a2, $s1		# Player x position
	move $a3, $s2		# Player y position
	jal test_collision_left # Check for collision
	li $a1, BTN_DANGER	# Test for danger button collision
	move $a2, $s1		# Player x position
	move $a3, $s2		# Player y position
	jal test_collision_left # Check for collision
	
	li $s7, 0		    # Set player movement flag to 0 (moved)
	bgtz $v0, continue_game_loop # If collision detected, skip movement
	addi $s1, $s1, -2	# Move player left by 2 units
	j continue_game_loop # Continue game loop
	
# Move player right
move_player_right:
	li $t5, 61		    # Right screen boundary
	li $t6, 60		    # Special case boundary
	li $v0, 0		    # Reset collision flag
	beq $s1, $t6, move_player_right_special	# Handle special case at x=60
	bge $s1, $t5, continue_game_loop	# If at right boundary, skip movement
	
	# Test for collision with terrain
	li $a1, TERRAIN_CLR	# Load terrain color
	move $a2, $s1		# Player x position
	move $a3, $s2		# Player y position
	jal test_collision_right # Check for collision
	
	li $s7, 0		    # Set player movement flag to 0 (moved)
	bgtz $v0, continue_game_loop # If collision detected, skip movement
	addi $s1, $s1, 2	# Move player right by 2 units
	j continue_game_loop # Continue game loop
	
# Special case for movement at x=60
move_player_right_special:
	li $s7, 0		    # Set player movement flag to 0 (moved)
	addi $s1, $s1, 1	# Move player right by 1 unit
	j continue_game_loop # Continue game loop
	
# Start jump
start_jump:
	li $v0, 0		    # Reset collision flag
	li $t6, JUMP_HEIGHT_MAX # Load maximum jump height
	beq $s5, $t6, finish_jump # If at max height, finish jump
	
	li $t5, 0		    # Top screen boundary
	beq $s2, $t5, jump_boundary # If at top boundary, handle jump boundary
	
	# Test for collision above
	li $a1, TERRAIN_CLR	# Load terrain color
	move $a2, $s1		# Player x position
	move $a3, $s2		# Player y position
	jal test_collision_above # Check for collision
	
	addi $s5, $s5, 1	# Increment jump counter
	li $s7, 0		    # Set player movement flag to 0 (moved)
	li $s6, 1		    # Set jumping flag to 1 (jumping)
	bgtz $v0, continue_game_loop # If collision detected, skip movement
	addi $s2, $s2, -1	# Move player up by 1 unit
	j continue_game_loop # Continue game loop
	
# Finish jump (reached max height)
finish_jump:
	li $v0, 0		    # Reset collision flag
	li $t5, 0		    # Top screen boundary
	beq $s2, $t5, jump_boundary # If at top boundary, handle jump boundary
	
	# Test for collision above
	li $a1, TERRAIN_CLR	# Load terrain color
	move $a2, $s1		# Player x position
	move $a3, $s2		# Player y position
	jal test_collision_above # Check for collision
	
	li $s5, 0		    # Reset jump counter
	li $s7, 0		    # Set player movement flag to 0 (moved)
	li $s6, 0		    # Set jumping flag to 0 (not jumping)
	bgtz $v0, continue_game_loop # If collision detected, skip movement
	addi $s2, $s2, -1	# Move player up by 1 unit
	j continue_game_loop # Continue game loop
	
# Handle jump at screen boundary
jump_boundary:
	li $s5, 0		    # Reset jump counter
	li $s7, 0		    # Set player movement flag to 0 (moved)
	li $s6, 0		    # Set jumping flag to 0 (not jumping)
	j continue_game_loop # Continue game loop
	
# Continue jump in progress
continue_jump:
	li $v0, 0		    # Reset collision flag
	li $t6, JUMP_HEIGHT_MAX # Load maximum jump height
	beq $s5, $t6, finish_jump_continue # If at max height, finish jump
	
	li $t5, 0		    # Top screen boundary
	beq $s2, $t5, jump_boundary_continue # If at top boundary, handle jump boundary
	
	addi $s5, $s5, 1	# Increment jump counter
	
	# Test for collision above
	li $a1, TERRAIN_CLR	# Load terrain color
	move $a2, $s1		# Player x position
	move $a3, $s2		# Player y position
	jal test_collision_above # Check for collision
	
	li $s7, 0		    # Set player movement flag to 0 (moved)
	li $s6, 1		    # Set jumping flag to 1 (jumping)
	bgtz $v0, process_game_state # If collision detected, process game state
	addi $s2, $s2, -1	# Move player up by 1 unit
	j process_game_state # Process game state
	
# Finish jump (reached max height) when continuing
finish_jump_continue:
	li $v0, 0		    # Reset collision flag
	li $t5, 0		    # Top screen boundary
	beq $s2, $t5, jump_boundary_continue # If at top boundary, handle jump boundary
	
	# Test for collision above
	li $a1, TERRAIN_CLR	# Load terrain color
	move $a2, $s1		# Player x position
	move $a3, $s2		# Player y position
	jal test_collision_above # Check for collision
	
	li $s5, 0		    # Reset jump counter
	li $s7, 0		    # Set player movement flag to 0 (moved)
	li $s6, 0		    # Set jumping flag to 0 (not jumping)
	bgtz $v0, process_game_state # If collision detected, process game state
	addi $s2, $s2, -1	# Move player up by 1 unit
	j process_game_state # Process game state
	
# Handle jump at screen boundary when continuing
jump_boundary_continue:
	li $s5, 0		    # Reset jump counter
	li $s7, 0		    # Set player movement flag to 0 (moved)
	li $s6, 0		    # Set jumping flag to 0 (not jumping)
	j process_game_state # Process game state
	
# Apply gravity to the player
apply_gravity:
	li $v0, 0		    # Reset collision flag
	
	# Check for ocean collision (defeat condition)
	li $a1, OCEAN_CLR	# Load ocean color
	move $a2, $s1		# Player x position
	move $a3, $s2		# Player y position
	jal test_collision_below # Test for collision
	bgtz $v0, game_over_defeat # If hit water, game over (defeat)
	
	# Check for button collision (victory condition)
	li $v0, 0		    # Reset collision flag
	li $a1, BTN_DANGER	# Load danger button color
	move $a2, $s1		# Player x position
	move $a3, $s2		# Player y position
	jal test_collision_below # Test for collision
	
	li $a1, BTN_NEUTRAL	# Load neutral button color
	move $a2, $s1		# Player x position
	move $a3, $s2		# Player y position
	jal test_collision_below # Test for collision
	bgtz $v0, game_over_victory # If hit button, game over (victory)
	
	# Check for terrain collision (standing on ground)
	li $v0, 0		    # Reset collision flag
	li $a1, TERRAIN_CLR	# Load terrain color
	move $a2, $s1		# Player x position
	move $a3, $s2		# Player y position
	jal test_collision_below # Test for collision
	bgtz $v0, on_ground # If on ground, handle on_ground state
	
	# Apply gravity if no collision below
	li $t5, 61		    # Bottom screen boundary
	beq $s2, $t5, process_game_state # If at bottom, process game state
	li $s7, 0		    # Set player movement flag to 0 (moved)
	addi $s2, $s2, 1	# Move player down by 1 unit
	j process_game_state # Process game state
	
# Player is on the ground
on_ground:
	li $s5, 0		    # Reset jump counter
	li $s6, 0		    # Set jumping flag to 0 (not jumping)
	j process_game_state # Process game state
	
# Restart the game
restart_game:
	jal resetDisplay    # Clear the display
	jal reset_game_vars # Reset game variables
	j setup             # Jump to setup

# Check for collision with collectible item
check_collision_item:
	addi $a1, $a0, 9	# Calculate item area x max
	addi $a3, $a2, 9	# Calculate item area y max
	bge $s1, $a0, test_item_x_max # If player x >= item x min, continue check
	jr $ra              # Return if no collision
test_item_x_max:
	ble $s1, $a1, test_item_y_min # If player x <= item x max, continue check
	jr $ra              # Return if no collision
test_item_y_min:
	bge $s2, $a2, test_item_y_max # If player y >= item y min, continue check
	jr $ra              # Return if no collision
test_item_y_max:
	ble $s2, $a3, item_collected # If player y <= item y max, item collected
	jr $ra              # Return if no collision
	
# Handle item collection
item_collected:
	addi $t2, $a0, 3	# Calculate item center x
	addi $t3, $a2, 3	# Calculate item center y
	move $a2, $t2		# Set x for clear operation
	move $a3, $t3		# Set y for clear operation
	
	addi $s0, $s0, 1	# Increment score
	jal clear_item		# Clear the collected item
	jal update_score_display	# Update score display
	j skip_item_checks  # Skip remaining item checks

# Update the score display based on current score
update_score_display:
	addi $sp, $sp, -4	# Adjust stack pointer
	sw $ra, 0($sp)		# Store return address
	
	jal clear_score_display	# Clear the current score display
	li $t1, 1 		    # Score value 1
	li $t2, 2           # Score value 2
	li $t3, 3           # Score value 3
	li $t4, 4 	        # Score value 4
	li $t5, 5 	        # Score value 5
	li $t6, 6           # Score value 6
	li $t7, 7           # Score value 7
	
	# Check score value and display appropriate number
	beq $s0, $t1, display_number_1	# If score is 1, display 1
	beq $s0, $t2, display_number_2  # If score is 2, display 2
	beq $s0, $t3, display_number_3  # If score is 3, display 3
	beq $s0, $t4, display_number_4  # If score is 4, display 4
	beq $s0, $t5, display_number_5  # If score is 5, display 5
	beq $s0, $t6, display_number_6  # If score is 6, display 6
	beq $s0, $t7, display_number_7  # If score is 7, display 7
	
finish_score_update:
	lw $ra, 0($sp)		# Load return address
	addi $sp, $sp, 4	# Adjust stack pointer
	jr $ra		        # Return

# Clear the score display area
clear_score_display:
	addi $sp, $sp, -4	# Adjust stack pointer
	sw $ra, 0($sp)		# Store return address
	
	# Clear score display area (5 rows)
	li $a0, VOID_CLR	# Load void/background color
	li $a1, 41		    # Start x position
	li $a2, 44		    # End x position
	li $a3, 58		    # First row y position
	jal renderHLine     # Draw horizontal line
	li $a1, 41		    # Start x position
	li $a2, 44		    # End x position
	li $a3, 59		    # Second row y position
	jal renderHLine     # Draw horizontal line
	li $a1, 41		    # Start x position
	li $a2, 44		    # End x position
	li $a3, 60		    # Third row y position
	jal renderHLine     # Draw horizontal line
	li $a1, 41		    # Start x position
	li $a2, 44		    # End x position
	li $a3, 61		    # Fourth row y position
	jal renderHLine     # Draw horizontal line
	li $a1, 41		    # Start x position
	li $a2, 44		    # End x position
	li $a3, 62		    # Fifth row y position
	jal renderHLine     # Draw horizontal line
	
	lw $ra, 0($sp)		# Load return address
	addi $sp, $sp, 4	# Adjust stack pointer
	jr $ra		        # Return
	
# Display digit 1 on score display
display_number_1:
	li $t1, BRIGHT_CLR	# Load bright color (white)
	sw $t1, 15020($t0)	# Draw pixel for digit 1
	sw $t1, 15272($t0)	# Draw pixel for digit 1
	sw $t1, 15276($t0)	# Draw pixel for digit 1
	sw $t1, 15532($t0)	# Draw pixel for digit 1
	sw $t1, 15788($t0)	# Draw pixel for digit 1
	sw $t1, 16044($t0)	# Draw pixel for digit 1
	sw $t1, 16040($t0)	# Draw pixel for digit 1
	sw $t1, 16048($t0)	# Draw pixel for digit 1
	j finish_score_update # Finish updating score
	
# Display digit 2 on score display
display_number_2:
	li $t1, BRIGHT_CLR	# Load bright color (white)
	sw $t1, 15016($t0)	# Draw pixel for digit 2
	sw $t1, 15020($t0)	# Draw pixel for digit 2
	sw $t1, 15268($t0)	# Draw pixel for digit 2
	sw $t1, 15280($t0)	# Draw pixel for digit 2
	sw $t1, 15532($t0)	# Draw pixel for digit 2
	sw $t1, 15784($t0)	# Draw pixel for digit 2
	sw $t1, 16036($t0)	# Draw pixel for digit 2
	sw $t1, 16040($t0)	# Draw pixel for digit 2
	sw $t1, 16044($t0)	# Draw pixel for digit 2
	sw $t1, 16048($t0)	# Draw pixel for digit 2
	j finish_score_update # Finish updating score

# Display digit 3 on score display
display_number_3:
	li $t1, BRIGHT_CLR	# Load bright color (white)
	sw $t1, 15016($t0)	# Draw pixel for digit 3
	sw $t1, 15020($t0)	# Draw pixel for digit 3
	sw $t1, 15268($t0)	# Draw pixel for digit 3
	sw $t1, 15280($t0)	# Draw pixel for digit 3
	sw $t1, 15532($t0)	# Draw pixel for digit 3
	sw $t1, 15792($t0)	# Draw pixel for digit 3
	sw $t1, 15780($t0)	# Draw pixel for digit 3
	sw $t1, 16040($t0)	# Draw pixel for digit 3
	sw $t1, 16044($t0)	# Draw pixel for digit 3
	j finish_score_update # Finish updating score

# Display digit 4 on score display
display_number_4:
	li $t1, BRIGHT_CLR	# Load bright color (white)
	sw $t1, 15012($t0)	# Draw pixel for digit 4
	sw $t1, 15268($t0)	# Draw pixel for digit 4
	sw $t1, 15528($t0)	# Draw pixel for digit 4
	sw $t1, 15532($t0)	# Draw pixel for digit 4
	sw $t1, 15024($t0)	# Draw pixel for digit 4
	sw $t1, 15280($t0)	# Draw pixel for digit 4
	sw $t1, 15536($t0)	# Draw pixel for digit 4
	sw $t1, 15792($t0)	# Draw pixel for digit 4
	sw $t1, 16048($t0)	# Draw pixel for digit 4
	j finish_score_update # Finish updating score

# Display digit 5 on score display
display_number_5:
	li $t1, BRIGHT_CLR	# Load bright color (white)
	sw $t1, 15016($t0)	# Draw pixel for digit 5
	sw $t1, 15020($t0)	# Draw pixel for digit 5
	sw $t1, 15024($t0)	# Draw pixel for digit 5
	sw $t1, 15272($t0)	# Draw pixel for digit 5
	sw $t1, 15528($t0)	# Draw pixel for digit 5
	sw $t1, 15532($t0)	# Draw pixel for digit 5
	sw $t1, 15536($t0)	# Draw pixel for digit 5
	sw $t1, 15792($t0)	# Draw pixel for digit 5
	sw $t1, 16044($t0)	# Draw pixel for digit 5
	sw $t1, 16040($t0)	# Draw pixel for digit 5
	j finish_score_update # Finish updating score
	
# Display digit 6 on score display
display_number_6:
	li $t1, BRIGHT_CLR	# Load bright color (white)
	sw $t1, 15016($t0)	# Draw pixel for digit 6
	sw $t1, 15020($t0)	# Draw pixel for digit 6
	sw $t1, 15268($t0)	# Draw pixel for digit 6
	sw $t1, 15524($t0)	# Draw pixel for digit 6
	sw $t1, 15528($t0)	# Draw pixel for digit 6
	sw $t1, 15532($t0)	# Draw pixel for digit 6
	sw $t1, 15780($t0)	# Draw pixel for digit 6
	sw $t1, 15792($t0)	# Draw pixel for digit 6
	sw $t1, 16040($t0)	# Draw pixel for digit 6
	sw $t1, 16044($t0)	# Draw pixel for digit 6
	j finish_score_update # Finish updating score

# Display digit 7 on score display
display_number_7:
	li $t1, BRIGHT_CLR	# Load bright color (white)
	sw $t1, 15012($t0)	# Draw pixel for digit 7
	sw $t1, 15016($t0)	# Draw pixel for digit 7
	sw $t1, 15020($t0)	# Draw pixel for digit 7
	sw $t1, 15280($t0)	# Draw pixel for digit 7
	sw $t1, 15532($t0)	# Draw pixel for digit 7
	sw $t1, 15784($t0)	# Draw pixel for digit 7
	sw $t1, 16040($t0)	# Draw pixel for digit 7
	j finish_score_update # Finish updating score

# Render the initial game world
renderInitialWorld:
	addi $sp, $sp, -4	# Adjust stack pointer
	sw $ra, 0($sp)		# Store return address
	
	# Draw deep water layer
	li $a0, DEEP_WATER_CLR   # Load deep water color
	li $a3, WATER_LEVEL1     # First water level y position
	li $a1, 0                # Start x position
	li $a2, 63               # End x position
	jal renderHLine          # Draw horizontal line

	# Draw ocean layer
	li $a0, OCEAN_CLR        # Load ocean color
	li $a3, WATER_LEVEL2     # Second water level y position
	li $a1, 0                # Start x position
	li $a2, 63               # End x position
	jal renderHLine          # Draw horizontal line

	# Draw shallow water layer
	li $a0, SHALLOW_WATER_CLR # Load shallow water color
	li $a3, WATER_LEVEL2      # Second water level y position
	addi $a3, $a3, -1         # One level above water level 2
	li $a1, 0                 # Start x position
	li $a2, 63                # End x position
	jal renderHLine           # Draw horizontal line
	
	# Draw wave details on shallow water
	li $t1, SHALLOW_WATER_CLR # Load shallow water color
	sw $t1, 14340($t0)       # Draw wave pixel
	sw $t1, 14360($t0)       # Draw wave pixel
	sw $t1, 14388($t0)       # Draw wave pixel
	sw $t1, 14400($t0)       # Draw wave pixel
	sw $t1, 14420($t0)       # Draw wave pixel
	sw $t1, 14452($t0)       # Draw wave pixel
	sw $t1, 14480($t0)       # Draw wave pixel
	sw $t1, 14500($t0)       # Draw wave pixel
	
	# Draw UI level line
	li $a0, BRIGHT_CLR	      # Load bright color (white)
	li $a3, UI_LEVEL         # UI level y position
	li $a1, 0                # Start x position
	li $a2, 63               # End x position
	jal renderHLine          # Draw horizontal line
	
	# Draw UI score display background
	li $a0, BRIGHT_CLR	      # Load bright color (white)
	li $a3, 58               # UI element y position
	li $a1, 10               # Start x position
	li $a2, 33               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, BRIGHT_CLR	      # Load bright color (white)
	li $a3, 59               # UI element y position
	li $a1, 10               # Start x position
	li $a2, 33               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, BRIGHT_CLR	      # Load bright color (white)
	li $a3, 60               # UI element y position
	li $a1, 10               # Start x position
	li $a2, 33               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, BRIGHT_CLR	      # Load bright color (white)
	li $a3, 61               # UI element y position
	li $a1, 10               # Start x position
	li $a2, 33               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, BRIGHT_CLR	      # Load bright color (white)
	li $a3, 62               # UI element y position
	li $a1, 10               # Start x position
	li $a2, 33               # End x position
	jal renderHLine          # Draw horizontal line
	
	# Cut out letters in UI score display background
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 58               # UI element y position
	li $a1, 10               # Start x position
	li $a2, 10               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 58               # UI element y position
	li $a1, 14               # Start x position
	li $a2, 15               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 58               # UI element y position
	li $a1, 19               # Start x position
	li $a2, 20               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 58               # UI element y position
	li $a1, 23               # Start x position
	li $a2, 24               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 58               # UI element y position
	li $a1, 28               # Start x position
	li $a2, 30               # End x position
	jal renderHLine          # Draw horizontal line
	
	# Continue cutting out letters in UI
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 59               # UI element y position
	li $a1, 11               # Start x position
	li $a2, 14               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 59               # UI element y position
	li $a1, 16               # Start x position
	li $a2, 19               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 59               # UI element y position
	li $a1, 21               # Start x position
	li $a2, 22               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 59               # UI element y position
	li $a1, 24               # Start x position
	li $a2, 24               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 59               # UI element y position
	li $a1, 26               # Start x position
	li $a2, 27               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 59               # UI element y position
	li $a1, 29               # Start x position
	li $a2, 29               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 59               # UI element y position
	li $a1, 31               # Start x position
	li $a2, 33               # End x position
	jal renderHLine          # Draw horizontal line
	
	# More UI letter cutouts
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 60               # UI element y position
	li $a1, 14               # Start x position
	li $a2, 14               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 60               # UI element y position
	li $a1, 16               # Start x position
	li $a2, 19               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 60               # UI element y position
	li $a1, 21               # Start x position
	li $a2, 22               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 60               # UI element y position
	li $a1, 24               # Start x position
	li $a2, 24               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 60               # UI element y position
	li $a1, 28               # Start x position
	li $a2, 29               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 60               # UI element y position
	li $a1, 33               # Start x position
	li $a2, 33               # End x position
	jal renderHLine          # Draw horizontal line
	
	# Continue with more UI letter cutouts
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 61               # UI element y position
	li $a1, 10               # Start x position
	li $a2, 12               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 61               # UI element y position
	li $a1, 14               # Start x position
	li $a2, 14               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 61               # UI element y position
	li $a1, 16               # Start x position
	li $a2, 19               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 61               # UI element y position
	li $a1, 21               # Start x position
	li $a2, 22               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 61               # UI element y position
	li $a1, 24               # Start x position
	li $a2, 24               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 61               # UI element y position
	li $a1, 26               # Start x position
	li $a2, 26               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 61               # UI element y position
	li $a1, 28               # Start x position
	li $a2, 29               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 61               # UI element y position
	li $a1, 31               # Start x position
	li $a2, 33               # End x position
	jal renderHLine          # Draw horizontal line
	
	# Final row of UI letter cutouts
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 62               # UI element y position
	li $a1, 13               # Start x position
	li $a2, 15               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 62               # UI element y position
	li $a1, 19               # Start x position
	li $a2, 20               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 62               # UI element y position
	li $a1, 23               # Start x position
	li $a2, 24               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 62               # UI element y position
	li $a1, 26               # Start x position
	li $a2, 27               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, VOID_CLR	      # Load void/background color
	li $a3, 62               # UI element y position
	li $a1, 29               # Start x position
	li $a2, 30               # End x position
	jal renderHLine          # Draw horizontal line
	
	# Draw UI score indicator marks
	li $a0, BRIGHT_CLR	      # Load bright color (white)
	li $a3, 59               # UI element y position
	li $a1, 36               # Start x position
	li $a2, 36               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, BRIGHT_CLR	      # Load bright color (white)
	li $a3, 61               # UI element y position
	li $a1, 36               # Start x position
	li $a2, 36               # End x position
	jal renderHLine          # Draw horizontal line
	
	# Draw UI score area pixel grid
	li $a0, BRIGHT_CLR	      # Load bright color (white)
	li $a3, 58               # UI element y position
	li $a1, 42               # Start x position
	li $a2, 43               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, BRIGHT_CLR	      # Load bright color (white)
	li $a3, 58               # UI element y position
	li $a1, 47               # Start x position
	li $a2, 48               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, BRIGHT_CLR	      # Load bright color (white)
	li $a3, 58               # UI element y position
	li $a1, 52               # Start x position
	li $a2, 53               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, BRIGHT_CLR	      # Load bright color (white)
	li $a3, 62               # UI element y position
	li $a1, 42               # Start x position
	li $a2, 43               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, BRIGHT_CLR	      # Load bright color (white)
	li $a3, 62               # UI element y position
	li $a1, 47               # Start x position
	li $a2, 48               # End x position
	jal renderHLine          # Draw horizontal line
	li $a0, BRIGHT_CLR	      # Load bright color (white)
	li $a3, 62               # UI element y position
	li $a1, 52               # Start x position
	li $a2, 53               # End x position
	jal renderHLine          # Draw horizontal line
	
	# Draw more UI elements
	li $a0, BRIGHT_CLR	      # Load bright color (white)
	sw $a0, 15268($t0)       # Draw UI element pixel
	sw $a0, 15524($t0)       # Draw UI element pixel
	sw $a0, 15780($t0)       # Draw UI element pixel
	sw $a0, 15280($t0)       # Draw UI element pixel
	sw $a0, 15536($t0)       # Draw UI element pixel
	sw $a0, 15792($t0)       # Draw UI element pixel
	sw $a0, 15288($t0)       # Draw UI element pixel
	sw $a0, 15544($t0)       # Draw UI element pixel
	sw $a0, 15800($t0)       # Draw UI element pixel
	sw $a0, 15300($t0)       # Draw UI element pixel
	sw $a0, 15556($t0)       # Draw UI element pixel
	sw $a0, 15812($t0)       # Draw UI element pixel
	sw $a0, 15308($t0)       # Draw UI element pixel
	sw $a0, 15564($t0)       # Draw UI element pixel
	sw $a0, 15820($t0)       # Draw UI element pixel
	sw $a0, 15320($t0)       # Draw UI element pixel
	sw $a0, 15576($t0)       # Draw UI element pixel
	sw $a0, 15832($t0)       # Draw UI element pixel
	
	# Draw game platforms
	li $a0, TERRAIN_CLR	      # Load terrain color
	li $a3, 49               # Platform y position
	li $a1, 0                # Start x position
	li $a2, 9                # End x position
	jal renderHLine          # Draw horizontal platform
	li $a0, TERRAIN_CLR	      # Load terrain color
	li $a3, 45               # Platform y position
	li $a1, 19               # Start x position
	li $a2, 27               # End x position
	jal renderHLine          # Draw horizontal platform
	li $a0, TERRAIN_CLR	      # Load terrain color
	li $a3, 40               # Platform y position
	li $a1, 33               # Start x position
	li $a2, 42               # End x position
	jal renderHLine          # Draw horizontal platform
	li $a0, TERRAIN_CLR	      # Load terrain color
	li $a3, 40               # Platform y position
	li $a1, 59               # Start x position
	li $a2, 63               # End x position
	jal renderHLine          # Draw horizontal platform
	li $a0, TERRAIN_CLR	      # Load terrain color
	li $a3, 33               # Platform y position
	li $a1, 21               # Start x position
	li $a2, 27               # End x position
	jal renderHLine          # Draw horizontal platform
	li $a0, TERRAIN_CLR	      # Load terrain color
	li $a3, 27               # Platform y position
	li $a1, 7                # Start x position
	li $a2, 15               # End x position
	jal renderHLine          # Draw horizontal platform
	li $a0, TERRAIN_CLR	      # Load terrain color
	li $a3, 27               # Platform y position
	li $a1, 59               # Start x position
	li $a2, 63               # End x position
	jal renderHLine          # Draw horizontal platform
	li $a0, TERRAIN_CLR	      # Load terrain color
	li $a3, 21               # Platform y position
	li $a1, 0                # Start x position
	li $a2, 3                # End x position
	jal renderHLine          # Draw horizontal platform
	li $a0, TERRAIN_CLR	      # Load terrain color
	li $a3, 17               # Platform y position
	li $a1, 25               # Start x position
	li $a2, 35               # End x position
	jal renderHLine          # Draw horizontal platform
	li $a0, TERRAIN_CLR	      # Load terrain color
	li $a3, 11               # Platform y position
	li $a1, 42               # Start x position
	li $a2, 51               # End x position
	jal renderHLine          # Draw horizontal platform
	li $a0, TERRAIN_CLR	      # Load terrain color
	li $a3, 6                # Platform y position
	li $a1, 0                # Start x position
	li $a2, 9                # End x position
	jal renderHLine          # Draw horizontal platform
	li $a0, TERRAIN_CLR	      # Load terrain color
	li $a3, 6                # Platform y position
	li $a1, 59               # Start x position
	li $a2, 63               # End x position
	jal renderHLine          # Draw horizontal platform
	
	# Draw game buttons
	li $a0, BTN_NEUTRAL      # Load neutral button color
	li $a3, 5                # Button y position
	li $a1, 1                # Start x position
	li $a2, 7                # End x position
	jal renderHLine          # Draw horizontal button
	li $a0, BTN_DANGER       # Load danger button color
	li $a3, 4                # Button y position
	li $a1, 2                # Start x position
	li $a2, 6                # End x position
	jal renderHLine          # Draw horizontal button
	
	# Draw obstacles
	li $a0, OBSTACLE_CLR     # Load obstacle color
	sw $a0, 36($t0)          # Draw obstacle pixel
	sw $a0, 292($t0)         # Draw obstacle pixel
	sw $a0, 548($t0)         # Draw obstacle pixel
	sw $a0, 804($t0)         # Draw obstacle pixel
	sw $a0, 1060($t0)        # Draw obstacle pixel
	sw $a0, 1316($t0)        # Draw obstacle pixel
	
	# Draw collectible items
	li $a2, 12               # Item 1 x position
	li $a3, 41               # Item 1 y position
	jal draw_item            # Draw the item

	li $a2, 35               # Item 2 x position
	li $a3, 26               # Item 2 y position
	jal draw_item            # Draw the item
	
	li $a2, 45               # Item 3 x position
	li $a3, 6                # Item 3 y position
	jal draw_item            # Draw the item

	# Draw powerups
	li $a0, POWER1_BASE      # Load blue powerup base color
	li $a1, 60               # Powerup x position
	li $a2, 62               # Powerup width
	li $a3, 36               # Powerup y position
	jal draw_powerup         # Draw blue powerup
	
	li $a0, POWER2_BASE      # Load green powerup base color
	li $a1, 29               # Powerup x position
	li $a2, 31               # Powerup width
	li $a3, 13               # Powerup y position
	jal draw_powerup         # Draw green powerup
	
	li $a0, POWER3_BASE      # Load violet powerup base color
	li $a1, 60               # Powerup x position
	li $a2, 62               # Powerup width
	li $a3, 2                # Powerup y position
	jal draw_powerup         # Draw violet powerup
	
	# Draw player at starting position
	li $a1, 2                # Player x position
	li $a3, 46               # Player y position
	jal draw_player          # Draw the player
	
	lw $ra, 0($sp)           # Load return address
	addi $sp, $sp, 4         # Adjust stack pointer
	jr $ra                   # Return
	
# Draw a powerup at position (a1,a2,a3) with color a0
draw_powerup:
	addi $sp, $sp, -4        # Adjust stack pointer
	sw $ra, 0($sp)           # Store return address
	move $t7, $a1            # Store x position in t7
	move $t8, $a2            # Store width in t8
	move $t9, $a3            # Store y position in t9
	
	# Check the powerup type and draw accordingly
	beq $a0, POWER1_BASE, draw_powerup_blue    # If blue powerup, use blue drawing
	beq $a0, POWER2_BASE, draw_powerup_green   # If green powerup, use green drawing
	



# Draw a horizontal line from (a1,a3) to (a2,a3) with color a0
renderHLine:
	addi $sp, $sp, -4        # Adjust stack pointer
	sw $ra, 0($sp)           # Store return address
	move $t1, $a0            # Store color in t1
	move $t2, $a1            # Store start x in t2
	move $t3, $a2            # Store end x in t3
	move $t4, $a3            # Store y position in t4
	sll $t2, $t2, 2          # Convert x to memory offset (x * 4)
	sll $t3, $t3, 2          # Convert end x to memory offset
	sll $t4, $t4, 8          # Convert y to memory offset (y * 256)
renderHLine_loop:
	add $t5, $t4, $t2        # Calculate total offset
	add $t6, $t5, $t0        # Calculate memory address
	sw $t1, 0($t6)           # Store color at memory address
	addi $t2, $t2, 4         # Move to next x position
	ble $t2, $t3, renderHLine_loop # If not at end yet, continue
	lw $ra, 0($sp)           # Load return address
	addi $sp, $sp, 4         # Adjust stack pointer
	jr $ra                   # Return
	
# Draw a vertical line from (a4,a2) to (a4,a3) with color a0
renderVLine:
	addi $sp, $sp, -4        # Adjust stack pointer
	sw $ra, 0($sp)           # Store return address
	move $t1, $a0            # Store color in t1
	move $t2, $a1            # Store start y in t2
	move $t3, $a2            # Store end y in t3
	move $t4, $a3            # Store x position in t4
	sll $t2, $t2, 8          # Convert start y to memory offset (y * 256)
	sll $t3, $t3, 8          # Convert end y to memory offset
	sll $t4, $t4, 2          # Convert x to memory offset (x * 4)

renderVLine_loop:
	add $t5, $t4, $t2        # Calculate total offset
	add $t6, $t5, $t0        # Calculate memory address
	sw $t1, 0($t6)           # Store color at memory address
	addi $t2, $t2, 256       # Move to next y position
	ble $t2, $t3, renderVLine_loop # If not at end yet, continue
	lw $ra, 0($sp)           # Load return address
	addi $sp, $sp, 4         # Adjust stack pointer
	jr $ra                   # Return

# Draw collectible item at position (a2,a3)
draw_item:
	addi $sp, $sp, -4        # Adjust stack pointer
	sw $ra, 0($sp)           # Store return address
	move $t2, $a2            # Store x position in t2
	move $t3, $a3            # Store y position in t3
	
	li $t1, TREASURE_PRIMARY # Load treasure primary color
	sll $t6, $t3, 8          # Convert y to memory offset (y * 256)
	sll $t4, $t2, 2          # Convert x to memory offset (x * 4)
	add $t4, $t4, $t6        # Calculate total offset
	
	# Draw item pixel by pixel
	addi $t6, $t4, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t4, 256       # Calculate offset for next row
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	
	li $t1, BRIGHT_CLR       # Load bright color (white)
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	
	li $t1, TREASURE_SECONDARY # Load treasure secondary color
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	
	li $t1, TREASURE_PRIMARY # Load treasure primary color
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t4, 512       # Calculate offset for next row
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	
	li $t1, TREASURE_SECONDARY # Load treasure secondary color
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	
	li $t1, TREASURE_PRIMARY # Load treasure primary color
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t4, 768       # Calculate offset for next row
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	
	lw $ra, 0($sp)           # Load return address
	addi $sp, $sp, 4         # Adjust stack pointer
	jr $ra                   # Return
	
# Clear collectible item at position (a2,a3)
clear_item:
	addi $sp, $sp, -4        # Adjust stack pointer
	sw $ra, 0($sp)           # Store return address
	move $t2, $a2            # Store x position in t2
	move $t3, $a3            # Store y position in t3
	
	li $t1, VOID_CLR         # Load void/background color
	sll $t6, $t3, 8          # Convert y to memory offset (y * 256)
	sll $t4, $t2, 2          # Convert x to memory offset (x * 4)
	add $t4, $t4, $t6        # Calculate total offset
	
	# Clear item pixel by pixel
	addi $t6, $t4, 4         # Calculate offset for pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t4, 256       # Calculate offset for next row
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t4, 512       # Calculate offset for next row
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t4, 768       # Calculate offset for next row
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	addi $t6, $t6, 4         # Calculate offset for next pixel
	add $t5, $t6, $t0        # Calculate memory address
	sw $t1, 0($t5)           # Store color at memory address
	
	lw $ra, 0($sp)           # Load return address
	addi $sp, $sp, 4         # Adjust stack pointer
	jr $ra                   # Return
	

	
draw_powerup_purple:
	li $a0, POWER3_BASE      # Load violet powerup base color
	move $a3, $t9            # Set y position
	move $a1, $t7            # Set x position
	move $a2, $t8            # Set width 
	jal renderHLine          # Draw horizontal line
	li $a0, POWER3_HIGHLIGHT # Load violet powerup highlight color
	move $a3, $t9            # Set y position
	addi $a3, $a3, 1         # Move to next row
	move $a1, $t7            # Set x position
	move $a2, $t8            # Set width
	jal renderHLine          # Draw horizontal line
	li $a0, BRIGHT_CLR       # Load bright color (white)
	move $a3, $t9            # Set y position
	addi $a3, $a3, 2         # Move to next row
	move $a1, $t7            # Set x position
	move $a2, $t8            # Set width
	jal renderHLine          # Draw horizontal line
	j draw_powerup_end       # Finish drawing
	
draw_powerup_blue:
	li $a0, POWER1_BASE      # Load blue powerup base color
	move $a3, $t9            # Set y position
	move $a1, $t7            # Set x position
	move $a2, $t8            # Set width
	jal renderHLine          # Draw horizontal line
	li $a0, POWER1_HIGHLIGHT # Load blue powerup highlight color
	move $a3, $t9            # Set y position
	addi $a3, $a3, 1         # Move to next row
	move $a1, $t7            # Set x position
	move $a2, $t8            # Set width
	jal renderHLine          # Draw horizontal line
	li $a0, BRIGHT_CLR       # Load bright color (white)
	move $a3, $t9            # Set y position
	addi $a3, $a3, 2         # Move to next row
	move $a1, $t7            # Set x position
	move $a2, $t8            # Set width
	jal renderHLine          # Draw horizontal line
	j draw_powerup_end       # Finish drawing
	
draw_powerup_green:
	li $a0, POWER2_BASE      # Load green powerup base color
	move $a3, $t9            # Set y position
	move $a1, $t7            # Set x position
	move $a2, $t8            # Set width
	jal renderHLine          # Draw horizontal line
	li $a0, POWER2_HIGHLIGHT # Load green powerup highlight color
	move $a3, $t9            # Set y position
	addi $a3, $a3, 1         # Move to next row
	move $a1, $t7            # Set x position
	move $a2, $t8            # Set width
	jal renderHLine          # Draw horizontal line
	li $a0, BRIGHT_CLR       # Load bright color (white)
	move $a3, $t9            # Set y position
	addi $a3, $a3, 2         # Move to next row
	move $a1, $t7            # Set x position
	move $a2, $t8            # Set width
	jal renderHLine          # Draw horizontal line
	j draw_powerup_end       # Finish drawing
	
draw_powerup_end:
	lw $ra, 0($sp)           # Load return address
	addi $sp, $sp, 4         # Adjust stack pointer
	jr $ra                   # Return
	
# Draw player character at position (a1,a3)
draw_player:
	addi $sp, $sp, -4        # Adjust stack pointer
	sw $ra, 0($sp)           # Store return address
	
	addi $a2, $a1, 2         # Calculate player width
	move $t7, $a1            # Store x position in t7
	move $t8, $a2            # Store width in t8
	move $t9, $a3            # Store y position in t9
	
    # Draw player head/hat
    li $a0, 0x424242         # Dark gray color for hat
    jal renderHLine          # Draw horizontal line
    
    # Draw player middle section
    li $a0, 0x757575         # Medium gray color for body
    move $a1, $t7            # Set x position
    move $a2, $t8            # Set width
    addi $a3, $t9, 1         # Move to next row
    jal renderHLine          # Draw horizontal line
    
    # Draw player eyes
    li $t1, 0xFF5252         # Red color for eyes
    sll $t2, $t9, 8          # Convert y to memory offset (y * 256)
    sll $t3, $t7, 2          # Convert x to memory offset (x * 4)
    add $t2, $t2, $t3        # Calculate total offset
    addi $t2, $t2, 256       # Move to next row
    add $t5, $t2, $t0        # Calculate memory address
    addi $t5, $t5, 4         # Adjust for eye position
    sw $t1, 0($t5)           # Store color at memory address
    
    # Draw player feet/base
    li $t1, 0xFF5252         # Red color for feet
    addi $t3, $t7, 2         # Calculate right side position
    sll $t3, $t3, 2          # Convert x to memory offset (x * 4)
    sll $t4, $t9, 8          # Convert y to memory offset (y * 256)
    addi $t4, $t4, 512       # Move down two rows
    add $t4, $t4, $t3        # Calculate total offset
    add $t5, $t4, $t0        # Calculate memory address
    sw $t1, 0($t5)           # Store color at memory address
    addi $t5, $t5, -8        # Move to left foot position
    sw $t1, 0($t5)           # Store color at memory address
	
	lw $ra, 0($sp)           # Load return address
	addi $sp, $sp, 4         # Adjust stack pointer
	jr $ra                   # Return

# Remove player from position (a1,a3)
remove_player:
	addi $sp, $sp, -4        # Adjust stack pointer
	sw $ra, 0($sp)           # Store return address
	addi $a2, $a1, 2         # Calculate player width
	move $t7, $a1            # Store x position in t7
	move $t8, $a2            # Store width in t8
	li $a0, VOID_CLR         # Load void/background color
	jal renderHLine          # Clear first row
	move $a1, $t7            # Reset x position
	move $a2, $t8            # Reset width
	addi $a3, $a3, 1         # Move to next row
	jal renderHLine          # Clear second row
	move $a1, $t7            # Reset x position
	move $a2, $t8            # Reset width
	addi $a3, $a3, 1         # Move to next row
	jal renderHLine          # Clear third row
	lw $ra, 0($sp)           # Load return address
	addi $sp, $sp, 4         # Adjust stack pointer
	jr $ra                   # Return
	
# Reset display to blank screen
resetDisplay:
	addi $sp, $sp, -4        # Adjust stack pointer
	sw $ra, 0($sp)           # Store return address
	li $t9, 63               # Maximum y value
	li $t7, 0                # Initialize y counter
	
clear_screen_loop:
	bgt $t7, $t9, clear_screen_end # If counter > max, exit loop
	li $a0, VOID_CLR         # Load void/background color
	li $a1, 0                # Start x position
	li $a2, 63               # End x position
	move $a3, $t7            # Current y position
	jal renderHLine          # Clear horizontal line
	addi $t7, $t7, 1         # Increment counter
	j clear_screen_loop      # Continue loop

clear_screen_end:
	lw $ra, 0($sp)           # Load return address
	addi $sp, $sp, 4         # Adjust stack pointer
	jr $ra                   # Return
	
# Clear game area but keep UI
clear_game_area:
	addi $sp, $sp, -4        # Adjust stack pointer
	sw $ra, 0($sp)           # Store return address
	li $t9, 56               # Maximum y value
	li $t7, 0                # Initialize y counter

clear_partial_loop:
	bgt $t7, $t9, clear_partial_end # If counter > max, exit loop
	li $a0, 0x6A0DAD         # Purple background color
	li $a1, 0                # Start x position
	li $a2, 63               # End x position
	move $a3, $t7            # Current y position
	jal renderHLine          # Clear horizontal line
	addi $t7, $t7, 1         # Increment counter
	j clear_partial_loop     # Continue loop

clear_partial_end:
	lw $ra, 0($sp)           # Load return address
	addi $sp, $sp, 4         # Adjust stack pointer
	jr $ra                   # Return

# Draw restart prompt in victory/defeat screen
draw_restart_prompt:
	addi $sp, $sp, -4        # Adjust stack pointer
	sw $ra, 0($sp)           # Store return address
	move $t1, $a0            # Store color in t1
	
	# Draw "Press P to restart" message pixel by pixel
	sw $t1, 8272($t0)        # Draw letter pixel
	sw $t1, 8276($t0)        # Draw letter pixel
	sw $t1, 8280($t0)        # Draw letter pixel
	sw $t1, 8528($t0)        # Draw letter pixel
	sw $t1, 8540($t0)        # Draw letter pixel
	sw $t1, 8784($t0)        # Draw letter pixel
	sw $t1, 8788($t0)        # Draw letter pixel
	sw $t1, 8792($t0)        # Draw letter pixel
	sw $t1, 9040($t0)        # Draw letter pixel
	sw $t1, 9296($t0)        # Draw letter pixel
	li $t1, BRIGHT_CLR       # Load bright color (white)
	sw $t1, 8004($t0)        # Draw letter pixel
	sw $t1, 8264($t0)        # Draw letter pixel
	sw $t1, 8032($t0)        # Draw letter pixel
	sw $t1, 8292($t0)        # Draw letter pixel
	sw $t1, 8060($t0)        # Draw letter pixel
	sw $t1, 8316($t0)        # Draw letter pixel
	sw $t1, 8572($t0)        # Draw letter pixel
	sw $t1, 8568($t0)        # Draw letter pixel
	sw $t1, 8576($t0)        # Draw letter pixel
	sw $t1, 8828($t0)        # Draw letter pixel
	sw $t1, 9084($t0)        # Draw letter pixel
	sw $t1, 9340($t0)        # Draw letter pixel
	sw $t1, 8588($t0)        # Draw letter pixel
	sw $t1, 8592($t0)        # Draw letter pixel
	sw $t1, 8840($t0)        # Draw letter pixel
	sw $t1, 9096($t0)        # Draw letter pixel
	sw $t1, 9356($t0)        # Draw letter pixel
	sw $t1, 9360($t0)        # Draw letter pixel
	sw $t1, 8852($t0)        # Draw letter pixel
	sw $t1, 9108($t0)        # Draw letter pixel
	sw $t1, 8360($t0)        # Draw letter pixel
	sw $t1, 8616($t0)        # Draw letter pixel
	sw $t1, 8872($t0)        # Draw letter pixel
	sw $t1, 8108($t0)        # Draw letter pixel
	sw $t1, 8112($t0)        # Draw letter pixel
	sw $t1, 8116($t0)        # Draw letter pixel
	sw $t1, 8120($t0)        # Draw letter pixel
	sw $t1, 8124($t0)        # Draw letter pixel
	sw $t1, 8128($t0)        # Draw letter pixel
	sw $t1, 8388($t0)        # Draw letter pixel
	sw $t1, 8644($t0)        # Draw letter pixel
	sw $t1, 8900($t0)        # Draw letter pixel
	sw $t1, 9156($t0)        # Draw letter pixel
	sw $t1, 9412($t0)        # Draw letter pixel
	sw $t1, 9668($t0)        # Draw letter pixel
	sw $t1, 9664($t0)        # Draw letter pixel
	sw $t1, 9660($t0)        # Draw letter pixel
	sw $t1, 9656($t0)        # Draw letter pixel
	sw $t1, 9652($t0)        # Draw letter pixel
	sw $t1, 9648($t0)        # Draw letter pixel
	sw $t1, 9912($t0)        # Draw letter pixel
	sw $t1, 10168($t0)       # Draw letter pixel
	sw $t1, 9400($t0)        # Draw letter pixel
	sw $t1, 9144($t0)        # Draw letter pixel
	sw $t1, 9908($t0)        # Draw letter pixel
	sw $t1, 9396($t0)        # Draw letter pixel
	
	lw $ra, 0($sp)           # Load return address
	addi $sp, $sp, 4         # Adjust stack pointer
	jr $ra                   # Return

# Draw first part of victory title
draw_victory_title_part1:
	addi $sp, $sp, -4        # Adjust stack pointer
	sw $ra, 0($sp)           # Store return address
	move $t9, $a0            # Store color in t9
	move $t2, $t9            # Copy color to t2
	
	# Draw "V" part of "VICTORY" pixel by pixel
	li $t1, BRIGHT_CLR       # Load bright color (white)
	sw $t1, 2092($t0)        # Draw letter pixel
	sw $t1, 2348($t0)        # Draw letter pixel
	sw $t1, 2604($t0)        # Draw letter pixel
	sw $t1, 2108($t0)        # Draw letter pixel
	sw $t1, 2364($t0)        # Draw letter pixel
	sw $t1, 2620($t0)        # Draw letter pixel
	sw $t1, 2864($t0)        # Draw letter pixel
	sw $t1, 2872($t0)        # Draw letter pixel
	sw $t1, 3124($t0)        # Draw letter pixel
	sw $t1, 3380($t0)        # Draw letter pixel
	sw $t1, 3636($t0)        # Draw letter pixel
	sw $t2, 2088($t0)        # Draw letter pixel (using game color)
	sw $t2, 2344($t0)        # Draw letter pixel (using game color)
	sw $t2, 2600($t0)        # Draw letter pixel (using game color)
	sw $t2, 2104($t0)        # Draw letter pixel (using game color)
	sw $t2, 2360($t0)        # Draw letter pixel (using game color)
	sw $t2, 2616($t0)        # Draw letter pixel (using game color)
	sw $t2, 2860($t0)        # Draw letter pixel (using game color)
	sw $t2, 2868($t0)        # Draw letter pixel (using game color)
	sw $t2, 3120($t0)        # Draw letter pixel (using game color)
	sw $t2, 3376($t0)        # Draw letter pixel (using game color)
	sw $t2, 3632($t0)        # Draw letter pixel (using game color)
	sw $t2, 2120($t0)        # Draw letter pixel (using game color)
	sw $t1, 2124($t0)        # Draw letter pixel (white)
	sw $t1, 2128($t0)        # Draw letter pixel (white)
	sw $t1, 2132($t0)        # Draw letter pixel (white)
	sw $t2, 3656($t0)        # Draw letter pixel (using game color)
	sw $t1, 3660($t0)        # Draw letter pixel (white)
	sw $t1, 3664($t0)        # Draw letter pixel (white)
	sw $t1, 3668($t0)        # Draw letter pixel (white)
	
	# Draw "I" in "VICTORY"
	move $a0, $t9            # Set color to game color
	li $a1, 9                # Start y position
	li $a2, 13               # End y position
	li $a3, 17               # X position
	jal renderVLine          # Draw vertical line
	
	# Draw horizontal bars
	li $a1, 43               # Start x position
	li $a2, 45               # End x position
	li $a3, 8                # Y position
	jal renderHLine          # Draw horizontal line
	li $a1, 43               # Start x position
	li $a2, 45               # End x position
	li $a3, 14               # Y position
	jal renderHLine          # Draw horizontal line
	
	# Draw vertical parts of final letters
	li $a0, SUCCESS_CLR      # Load success color (green)
	li $a1, 8                # Start y position
	li $a2, 14               # End y position
	li $a3, 47               # X position
	jal renderVLine          # Draw vertical line
	li $a1, 10               # Start y position
	li $a2, 12               # End y position
	li $a3, 49               # X position
	jal renderVLine          # Draw vertical line
	li $a1, 8                # Start y position
	li $a2, 14               # End y position
	li $a3, 51               # X position
	jal renderVLine          # Draw vertical line
	li $a0, BRIGHT_CLR       # Load bright color (white)
	li $a1, 8                # Start y position
	li $a2, 14               # End y position
	li $a3, 48               # X position
	jal renderVLine          # Draw vertical line
	li $a1, 10               # Start y position
	li $a2, 12               # End y position
	li $a3, 50               # X position
	jal renderVLine          # Draw vertical line
	li $a1, 8                # Start y position
	li $a2, 14               # End y position
	li $a3, 52               # X position
	jal renderVLine          # Draw vertical line
	
	# Draw final letter pixels
	li $t1, BRIGHT_CLR       # Load bright color (white)
	sw $t1, 2500($t0)        # Draw letter pixel
	sw $t1, 3532($t0)        # Draw letter pixel
	li $t1, SUCCESS_CLR      # Load success color (green)
	sw $t1, 3528($t0)        # Draw letter pixel
	
	lw $ra, 0($sp)           # Load return address
	addi $sp, $sp, 4         # Adjust stack pointer
	jr $ra                   # Return


# Draw second part of defeat title
draw_defeat_title_part2:
	addi $sp, $sp, -4        # Adjust stack pointer
	sw $ra, 0($sp)           # Store return address
	
	# Draw "E" of "DEFEAT"
	li $a0, FAILURE_CLR      # Load failure color (red)
	li $a1, 8                # Start y position
	li $a2, 13               # End y position
	li $a3, 35               # X position
	jal renderVLine          # Draw vertical line
	li $a0, BRIGHT_CLR       # Load bright color (white)
	li $a1, 8                # Start y position
	li $a2, 13               # End y position
	li $a3, 36               # X position
	jal renderVLine          # Draw vertical line
	
	# Draw parts of "A" in "DEFEAT"
	li $t1, FAILURE_CLR      # Load failure color (red)
	sw $t1, 3728($t0)        # Draw letter pixel
	li $t1, BRIGHT_CLR       # Load bright color (white)
	sw $t1, 3732($t0)        # Draw letter pixel
	sw $t1, 3736($t0)        # Draw letter pixel
	sw $t1, 3740($t0)        # Draw letter pixel
	
	# Draw more parts of "A" and "T" in "DEFEAT"
	li $t1, FAILURE_CLR      # Load failure color (red)
	sw $t1, 2212($t0)        # Draw letter pixel
	sw $t1, 3748($t0)        # Draw letter pixel
	li $t1, BRIGHT_CLR       # Load bright color (white)
	sw $t1, 2216($t0)        # Draw letter pixel
	sw $t1, 2220($t0)        # Draw letter pixel
	sw $t1, 2224($t0)        # Draw letter pixel
	sw $t1, 3752($t0)        # Draw letter pixel
	sw $t1, 3756($t0)        # Draw letter pixel
	sw $t1, 3760($t0)        # Draw letter pixel
	
	# Draw "T" in "DEFEAT"
	li $a0, FAILURE_CLR      # Load failure color (red)
	li $a1, 9                # Start y position
	li $a2, 13               # End y position
	li $a3, 40               # X position
	jal renderVLine          # Draw vertical line
	li $a1, 9                # Start y position
	li $a2, 13               # End y position
	li $a3, 44               # X position
	jal renderVLine          # Draw vertical line
	li $a0, BRIGHT_CLR       # Load bright color (white)
	li $a1, 9                # Start y position
	li $a2, 13               # End y position
	li $a3, 41               # X position
	jal renderVLine          # Draw vertical line
	li $a1, 9                # Start y position
	li $a2, 13               # End y position
	li $a3, 45               # X position
	jal renderVLine          # Draw vertical line
	
	# Draw pixels for letters in "DEFEAT"
	li $t1, FAILURE_CLR      # Load failure color (red)
	sw $t1, 2240($t0)        # Draw letter pixel
	sw $t1, 2492($t0)        # Draw letter pixel
	sw $t1, 2748($t0)        # Draw letter pixel
	sw $t1, 3008($t0)        # Draw letter pixel
	sw $t1, 3268($t0)        # Draw letter pixel
	sw $t1, 3272($t0)        # Draw letter pixel
	sw $t1, 3276($t0)        # Draw letter pixel
	sw $t1, 3532($t0)        # Draw letter pixel
	sw $t1, 3772($t0)        # Draw letter pixel
	
	# Draw horizontal parts of letters
	li $a0, BRIGHT_CLR       # Load bright color (white)
	li $a1, 49               # Start x position
	li $a2, 52               # End x position
	li $a3, 8                # Y position
	jal renderHLine          # Draw horizontal line
	li $a1, 49               # Start x position
	li $a2, 51               # End x position
	li $a3, 11               # Y position
	jal renderHLine          # Draw horizontal line
	li $a1, 48               # Start x position
	li $a2, 51               # End x position
	li $a3, 14               # Y position
	jal renderHLine          # Draw horizontal line
	
	# Draw more pixels for letters
	li $t1, BRIGHT_CLR       # Load bright color (white)
	sw $t1, 2496($t0)        # Draw letter pixel
	sw $t1, 2752($t0)        # Draw letter pixel
	sw $t1, 3280($t0)        # Draw letter pixel
	sw $t1, 3536($t0)        # Draw letter pixel
	li $t1, FAILURE_CLR      # Load failure color (red)
	sw $t1, 2268($t0)        # Draw letter pixel
	sw $t1, 3804($t0)        # Draw letter pixel
	
	# Draw vertical parts of "T" in "DEFEAT"
	li $a0, FAILURE_CLR      # Load failure color (red)
	li $a1, 9                # Start y position
	li $a2, 13               # End y position
	li $a3, 54               # X position
	jal renderVLine          # Draw vertical line
	li $a0, BRIGHT_CLR       # Load bright color (white)
	li $a1, 9                # Start y position
	li $a2, 13               # End y position
	li $a3, 55               # X position
	jal renderVLine          # Draw vertical line
	
	# Draw horizontal parts of last letter
	li $a1, 56               # Start x position
	li $a2, 59               # End x position
	li $a3, 8                # Y position
	jal renderHLine          # Draw horizontal line
	li $a1, 56               # Start x position
	li $a2, 58               # End x position
	li $a3, 11               # Y position
	jal renderHLine          # Draw horizontal line
	li $a1, 56               # Start x position
	li $a2, 59               # End x position
	li $a3, 14               # Y position
	jal renderHLine          # Draw horizontal line
	
	lw $ra, 0($sp)           # Load return address
	addi $sp, $sp, 4         # Adjust stack pointer
	jr $ra                   # Return

# Draw second part of victory title
# Draw second part of victory title
draw_victory_title_part2:
	addi $sp, $sp, -4        # Adjust stack pointer
	sw $ra, 0($sp)           # Store return address
	
	# Draw "Y" of "VICTORY"
	li $a0, SUCCESS_CLR      # Load success color (green)
	li $a1, 8                # Start y position
	li $a2, 13               # End y position
	li $a3, 35               # X position
	jal renderVLine          # Draw vertical line
	li $a0, BRIGHT_CLR       # Load bright color (white)
	li $a1, 8                # Start y position
	li $a2, 13               # End y position
	li $a3, 36               # X position
	jal renderVLine          # Draw vertical line
	
	# Draw more parts of "Y"
	li $a0, SUCCESS_CLR      # Load success color (green)
	li $a1, 8                # Start y position
	li $a2, 13               # End y position
	li $a3, 39               # X position
	jal renderVLine          # Draw vertical line
	li $a0, BRIGHT_CLR       # Load bright color (white)
	li $a1, 8                # Start y position
	li $a2, 13               # End y position
	li $a3, 40               # X position
	jal renderVLine          # Draw vertical line
	
	# Draw pixels for "Y"
	li $t1, SUCCESS_CLR      # Load success color (green)
	sw $t1, 3728($t0)        # Draw letter pixel
	li $t1, BRIGHT_CLR       # Load bright color (white)
	sw $t1, 3732($t0)        # Draw letter pixel
	sw $t1, 3740($t0)        # Draw letter pixel
	sw $t1, 3480($t0)        # Draw letter pixel
	sw $t1, 3224($t0)        # Draw letter pixel
	
	# Draw parts of remaining letters
	li $a0, SUCCESS_CLR      # Load success color (green)
	li $a1, 8                # Start y position
	li $a2, 9                # End y position
	li $a3, 42               # X position
	jal renderVLine          # Draw vertical line
	li $a1, 9                # Start y position
	li $a2, 14               # End y position
	li $a3, 43               # X position
	jal renderVLine          # Draw vertical line
	li $a0, SUCCESS_CLR      # Load success color (green)
	li $a1, 13               # Start y position
	li $a2, 14               # End y position
	li $a3, 42               # X position
	jal renderVLine          # Draw vertical line
	li $a0, BRIGHT_CLR       # Load bright color (white)
	li $a1, 9                # Start y position
	li $a2, 14               # End y position
	li $a3, 44               # X position
	jal renderVLine          # Draw vertical line
	
	# Draw horizontal bars
	li $a1, 43               # Start x position
	li $a2, 45               # End x position
	li $a3, 8                # Y position
	jal renderHLine          # Draw horizontal line
	li $a1, 43               # Start x position
	li $a2, 45               # End x position
	li $a3, 14               # Y position
	jal renderHLine          # Draw horizontal line
	
	# Draw vertical parts of final letters
	li $a0, SUCCESS_CLR      # Load success color (green)
	li $a1, 8                # Start y position
	li $a2, 14               # End y position
	li $a3, 47               # X position
	jal renderVLine          # Draw vertical line
	li $a1, 10               # Start y position
	li $a2, 12               # End y position
	li $a3, 49               # X position
	jal renderVLine          # Draw vertical line
	li $a1, 8                # Start y position
	li $a2, 14               # End y position
	li $a3, 51               # X position
	jal renderVLine          # Draw vertical line
	li $a0, BRIGHT_CLR       # Load bright color (white)
	li $a1, 8                # Start y position
	li $a2, 14               # End y position
	li $a3, 48               # X position
	jal renderVLine          # Draw vertical line
	li $a1, 10               # Start y position
	li $a2, 12               # End y position
	li $a3, 50               # X position
	jal renderVLine          # Draw vertical line
	li $a1, 8                # Start y position
	li $a2, 14               # End y position
	li $a3, 52               # X position
	jal renderVLine          # Draw vertical line
	
	# Draw final letter pixels
	li $t1, BRIGHT_CLR       # Load bright color (white)
	sw $t1, 2500($t0)        # Draw letter pixel
	sw $t1, 3532($t0)        # Draw letter pixel
	li $t1, SUCCESS_CLR      # Load success color (green)
	sw $t1, 3528($t0)        # Draw letter pixel
	
	lw $ra, 0($sp)           # Load return address
	addi $sp, $sp, 4         # Adjust stack pointer
	jr $ra                   # Return

# Reset all game variables to their initial state
reset_game_vars:
	addi $sp, $sp, -4        # Adjust stack pointer
	sw $ra, 0($sp)           # Store return address
	
	# Reset all registers used by the game
	move $t1, $0             # Clear t1
	move $t2, $0             # Clear t2
	move $t3, $0             # Clear t3
	move $t4, $0             # Clear t4
	move $t5, $0             # Clear t5
	move $t6, $0             # Clear t6
	move $t7, $0             # Clear t7
	move $t8, $0             # Clear t8
	move $t9, $0             # Clear t9
	move $s0, $0             # Clear score
	move $s1, $0             # Clear player x position
	move $s2, $0             # Clear player y position
	move $s3, $0             # Clear EntityData pointer
	move $s4, $0             # Clear WorldData pointer
	move $s5, $0             # Clear jump counter
	move $s6, $0             # Clear jump state flag
	move $s7, $0             # Clear player movement flag
	
	lw $ra, 0($sp)           # Load return address
	addi $sp, $sp, 4         # Adjust stack pointer
	jr $ra                   # Return

# Draw first part of defeat title
draw_defeat_title_part1:
	addi $sp, $sp, -4        # Adjust stack pointer
	sw $ra, 0($sp)           # Store return address
	move $t9, $a0            # Store color in t9
	move $t2, $t9            # Copy color to t2
	
	# Draw "D" of "DEFEAT" pixel by pixel
	li $t1, BRIGHT_CLR       # Load bright color (white)
	sw $t1, 2092($t0)        # Draw letter pixel
	sw $t1, 2348($t0)        # Draw letter pixel
	sw $t1, 2604($t0)        # Draw letter pixel
	sw $t1, 2108($t0)        # Draw letter pixel
	sw $t1, 2364($t0)        # Draw letter pixel
	sw $t1, 2620($t0)        # Draw letter pixel
	sw $t1, 2864($t0)        # Draw letter pixel
	sw $t1, 2872($t0)        # Draw letter pixel
	sw $t1, 3124($t0)        # Draw letter pixel
	sw $t1, 3380($t0)        # Draw letter pixel
	sw $t1, 3636($t0)        # Draw letter pixel
	sw $t2, 2088($t0)        # Draw letter pixel (using game color)
	sw $t2, 2344($t0)        # Draw letter pixel (using game color)
	sw $t2, 2600($t0)        # Draw letter pixel (using game color)
	sw $t2, 2104($t0)        # Draw letter pixel (using game color)
	sw $t2, 2360($t0)        # Draw letter pixel (using game color)
	sw $t2, 2616($t0)        # Draw letter pixel (using game color)
	sw $t2, 2860($t0)        # Draw letter pixel (using game color)
	sw $t2, 2868($t0)        # Draw letter pixel (using game color)
	sw $t2, 3120($t0)        # Draw letter pixel (using game color)
	sw $t2, 3376($t0)        # Draw letter pixel (using game color)
	sw $t2, 3632($t0)        # Draw letter pixel (using game color)
	sw $t2, 2120($t0)        # Draw letter pixel (using game color)
	sw $t1, 2124($t0)        # Draw letter pixel (white)
	sw $t1, 2128($t0)        # Draw letter pixel (white)
	sw $t1, 2132($t0)        # Draw letter pixel (white)
	sw $t2, 3656($t0)        # Draw letter pixel (using game color)
	sw $t1, 3660($t0)        # Draw letter pixel (white)
	sw $t1, 3664($t0)        # Draw letter pixel (white)
	sw $t1, 3668($t0)        # Draw letter pixel (white)
	
	# Draw vertical line for "E" in "DEFEAT"
	move $a0, $t9            # Set color to game color
	li $a1, 9                # Start y position
	li $a2, 13               # End y position
	li $a3, 17               # X position
	jal renderVLine          # Draw vertical line
	li $a0, BRIGHT_CLR       # Load bright color (white)
	li $a1, 9                # Start y position
	li $a2, 13               # End y position
	li $a3, 18               # X position
	jal renderVLine          # Draw vertical line
	
	# Draw vertical line for "F" in "DEFEAT"
	move $a0, $t9            # Set color to game color
	li $a1, 9                # Start y position
	li $a2, 13               # End y position
	li $a3, 21               # X position
	jal renderVLine          # Draw vertical line
	li $a0, BRIGHT_CLR       # Load bright color (white)
	li $a1, 9                # Start y position
	li $a2, 13               # End y position
	li $a3, 22               # X position
	jal renderVLine          # Draw vertical line
	
	# Draw vertical line for "E" in "DEFEAT"
	move $a0, $t9            # Set color to game color
	li $a1, 8                # Start y position
	li $a2, 13               # End y position
	li $a3, 24               # X position
	jal renderVLine          # Draw vertical line
	li $a0, BRIGHT_CLR       # Load bright color (white)
	li $a1, 8                # Start y position
	li $a2, 13               # End y position
	li $a3, 25               # X position
	jal renderVLine          # Draw vertical line
	
	# Draw vertical line for "A" in "DEFEAT"
	move $a0, $t9            # Set color to game color
	li $a1, 8                # Start y position
	li $a2, 13               # End y position
	li $a3, 28               # X position
	jal renderVLine          # Draw vertical line
	li $a0, BRIGHT_CLR       # Load bright color (white)
	li $a1, 8                # Start y position
	li $a2, 13               # End y position
	li $a3, 29               # X position
	jal renderVLine          # Draw vertical line
	
	# Draw horizontal part of "T" in "DEFEAT"
	li $t1, BRIGHT_CLR       # Load bright color (white)
	move $t2, $t9            # Copy game color to t2
	sw $t2, 3684($t0)        # Draw letter pixel (using game color)
	sw $t1, 3688($t0)        # Draw letter pixel (white)
	sw $t1, 3692($t0)        # Draw letter pixel (white)
	sw $t1, 3696($t0)        # Draw letter pixel (white)
	
	lw $ra, 0($sp)           # Load return address
	addi $sp, $sp, 4         # Adjust stack pointer
	jr $ra                   # Return

# Victory game over screen
game_over_victory:
	jal clear_game_area      # Clear the game area
	li $a0, SUCCESS_CLR      # Load success color (green)
	jal draw_restart_prompt  # Draw the restart prompt
	jal draw_victory_title_part1 # Draw first part of victory title
	jal draw_victory_title_part2 # Draw second part of victory title
	j wait_for_restart       # Jump to restart waiting loop
	
# Defeat game over screen
game_over_defeat:
	jal clear_game_area      # Clear the game area
	li $a0, FAILURE_CLR      # Load failure color (red)
	jal draw_restart_prompt  # Draw the restart prompt
	jal draw_defeat_title_part1 # Draw first part of defeat title
	jal draw_defeat_title_part2 # Draw second part of defeat title
	j wait_for_restart       # Jump to restart waiting loop

# Restart the entire game from beginning
restart_all:
	jal resetDisplay         # Clear the display
	jal reset_game_vars      # Reset game variables
	j setup                  # Jump to setup routine