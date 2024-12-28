extends Node

## A weapon consists of a tree of connected parts, with some being optional
# Each weapon starts with a grip, which defines the type of the weapon (melee,
# ranged, shield), as well as controlling the moveset and animations

# Some special/legendary weapons could occupy both equipment slots, but most
# would be either a melee weapon, ranged weapon, or shield, and occupy one slot

## Sockets on parts allow other parts to be attached
# A basic sword handle might have sockets for a pommel, small guard, and a
# medium blade, while a shield handle might have sockets for a large guard and
# a small blade, acting as shield spikes. Those parts, in turn, might have
# sockets for gems or other parts.

## The first socket is the root
# The type for this socket should match the type of the weapon part. When parts
# are connected, the root and socket are aligned to position the part. The root
# socket for grips determines the player hand position on the weapon.
