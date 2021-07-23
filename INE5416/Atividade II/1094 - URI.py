rows_number = int(input())

total = 0
c_type = 0
r_type = 0
s_type = 0

for _ in range(rows_number):
	animals_number, type_aninal = input().split()
	animals_number = int(animals_number)
	type_aninal = str(type_aninal)

	if type_aninal == 'C':
		c_type += animals_number
	elif type_aninal == 'R':
		r_type += animals_number
	else:
		s_type += animals_number

	total += animals_number

print('Total: %d cobaias' % total)
print('Total de coelhos: %d' % c_type)
print('Total de ratos: %d' % r_type)
print('Total de sapos: %d' % s_type)

if c_type == 0:
	print('Percentual de coelhos: %.2f %%' % 0)
else:
	print('Percentual de coelhos: %.2f %%' % (100*c_type/total))
if r_type == 0:
	print('Percentual de ratos: %.2f %%' % 0)
else:
	print('Percentual de ratos: %.2f %%' % (100*r_type/total))
if s_type == 0:
	print('Percentual de sapos: %.2f %%' % 0)
else:
	print('Percentual de sapos: %.2f %%' % (100*s_type/total))