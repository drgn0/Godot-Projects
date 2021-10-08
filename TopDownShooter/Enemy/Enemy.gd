extends KinematicBody2D

class_name Enemy

signal get_damage(damage) 
signal get_knockback(intensity, impact_position)


export var coin_scene = preload("res://UI/Coin.tscn")


export (int) var maxSpeed 
export (int) var linear_acceleration
export (int) var angular_acceleration

export (int) var max_health
