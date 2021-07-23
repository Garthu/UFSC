from dataclasses import dataclass, field
from abc import abstractmethod

@dataclass
class _Humam:
	height: int = 0

@dataclass
class _Animal:
	genre: str
	age: int
	is_mammal: bool = 0
				# Base class

	def static_function():
		print("This is a static function!")
				# This is a demonstration of an
				# static function, a class function
				# that don't use the internal data
				# of the class

	def print_genre(self):
		print(f"The genre of this animal is: {self.genre}")
				# Just a normal function

@dataclass
class _BabyBase:
	father: str
	mother: str

	@abstractmethod
	def print_father(self):
		pass
				# Abstract function, a function
				# that can be changed in every
				# class that has inheritanced
				# from this class

	@abstractmethod
	def print_mother(self):
		pass
				# Another abstract function

@dataclass
class Claw:
	length: int = 0

@dataclass
class _Platypus(_Animal):
	color: str = 'null'
	claw: Claw = field(default_factory=Claw)
				# Exempl of simple inheritance
				# with composition

@dataclass
class _BabyPlatypus(_Platypus, _BabyBase):
				# Example of a multiple inheri-
				# tance

	def print_father(self):
		print(self.father)

	def print_mother(self):
		print(self.mother)

@dataclass
class _Humanoid(_Humam, _Animal):
	def print_genre(self):
		print(f"The genre of this humanoid is: {self.genre}")
				# Polimorfe function