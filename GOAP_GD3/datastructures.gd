extends Node
# Holds datastructures subclasses
const LOG2BASEE = 0.69314718056
class PriorityQueue: 
	# Version 1.0.4
	
	# Reference class. Does not need to be freed manually
	
	# Holds an arbitrary number of values sorted by a weight assigned to set values
	# Structure is a balanced BST
	# In order to compare non-int values, the input is in form of an array of size 2
	#  - 0: priority value in form of int or float
	#  - 1: value to store
	
	var isEmpty = true
	var currentSize = 0 # Number of elements in heap
	var array = [null] # The array holding the values
	var maintain_min
	var lastPowerOfTwo = 0
	
	func _init(array_of_items, set_maintain_min = true):
		maintain_min = set_maintain_min # Determines whether the smalles value is maintained at the top or the biggest
		if (array_of_items.size() > 0):
			lastPowerOfTwo = ceil(log(array_of_items.size()) / LOG2BASEE)
			array.resize(pow(2, lastPowerOfTwo) + 1)
			currentSize = array_of_items.size()
			
			# Randomly populate array
			var i = 0
			while (i < array_of_items.size()):
				array[i + 1] = array_of_items[i]
				i += 1

			build_heap()

		else:
			currentSize = 0
			isEmpty = true
	
	func build_heap():
		# Establishes heap order property from an arbitrary arrangement of items. Runs in linear time
		var i = currentSize / 2 # Start with lowest, rightmost internal node
		while (i > 0):
			percolate_down(i)
			i -= 1
		isEmpty = currentSize < 1
	
	func get_maintain_min():
		# true means the root node is the one with lowest value
		# false means the queue will sort the highest value to the front
		return maintain_min

	func get_root_item():
		# Returns the smallest / biggest item ( = root) without deleting it
		if (!isEmpty):
			return array[1]
		return null

	func get_root_value():
		# Returns the value of the smallest / biggest item ( = root) without deleting it
		if (!isEmpty):
			return array[1][1]
		return null
	
	func get_root_priority():
		# Returns the priority of root object
		if (isEmpty):
			return -1
		return array[1][0]

	func get_item_priority(arrayIdx):
		if (arrayIdx + 1 > currentSize || arrayIdx < 0):
			print(str(OS.get_ticks_msec()) + ": PRIORITY QUEUE (" + str(get_instance_id()) + "): get_item_priority(arrayIdx) out of bounds! arrayIdx = " + str(arrayIdx) + ", currentSize = " + str(currentSize))
			return false
		return array[arrayIdx + 1][0]
	
	func get_item_value(arrayIdx):
		if (arrayIdx + 1 > currentSize || arrayIdx < 0):
			print(str(OS.get_ticks_msec()) + ": PRIORITY QUEUE (" + str(get_instance_id()) + "): get_item_priority(arrayIdx) out of bounds! arrayIdx = " + str(arrayIdx) + ", currentSize = " + str(currentSize))
			return false
		return array[arrayIdx + 1][1]
	
	func get_queue():
		# Returns the complete queue without first (empty) entry as simple array
		var list = []
		var i = 0
		while (i < array.size()):
			if (array[i] != null):
				list.append(array[i][1])
			i += 1
		return list
	
	func get_height():
		# Returns the number of 'tiers' with at least one element in it
		return ceil(log(array.size() - 1) / LOG2BASEE)

	func get_size():
		# Returns number of elements in the queue
		return currentSize
	func insert(priority, value):
		# Allows duplicates of priorities
		# Insert new element into heap at the next available slot. Calling that "hole"
		# Then percolate the element up in the heap while heap-order property is not satisfied

		# Check validity of input
		if (typeof(priority) != TYPE_INT && typeof(priority) != TYPE_REAL):
			print(str(OS.get_ticks_msec()) + ": PRIORITY QUEUE (" + str(get_instance_id()) + "): Priority of incorrect type (" + str(typeof(priority)) + ") (should be float or int)! Aborting insert()")
			return false
		
		# Check for space left in array. If filled, open up a new layer
		if (currentSize == array.size() - 1):
			array.resize(array.size() * 2)
			lastPowerOfTwo += 1
		
		# Percolate up. Starting hole at the last free index of the array, move the hole downwards until the parent node is smaller than the priority we want to sort in
		currentSize += 1
		isEmpty = currentSize < 0
		array[currentSize] = [priority, value]
		percolate_up(currentSize)
		# Successfully inserted
		return true

	func remove_root(return_array = false):
		# Deletes minimum element
		# Minimum element is always at the root
		# Heap decreases by one in size
		# Move last element into hole at root
		# Percolate down while heap-order not satisfied
		if (isEmpty):
			print(str(OS.get_ticks_msec()) + ": PRIORITY QUEUE (" + str(get_instance_id()) + "): Can't delete root in empty heap! isEmpty = true, currentSize = " + str(currentSize))
			return null
		var rootItem
		if (return_array):
			rootItem = array[1]
		else:
			rootItem = array[1][1]
		
		array[1] = array[currentSize] # Place last element in front
		currentSize -= 1 # Reduce size
		percolate_down(1) # Let last element ripple down to reestablish heap order
		isEmpty = currentSize < 1
		
		# Resize array (remove_root() is the only function to remove any items, since remove_and_collide() calls this)
		if (currentSize == pow(2, lastPowerOfTwo - 1)):
			lastPowerOfTwo -= 1
			array.resize(pow(2, lastPowerOfTwo) + 1)
		return rootItem

	func percolate_down(hole):
		# Internal method to percolate down in the heap
		# hole is the index at which the percolate begins
		var child
		var tmp = array[hole]
		while (hole * 2 <= currentSize):
			if (maintain_min): 
				# Sort so smallest value is root
				# hole * 2 is left child, child + 1 is the right child
				child = hole * 2
				if (child != currentSize && array[child + 1][0] < array[child][0]):
					child += 1
				
				if (array[child][0] < tmp[0]):
					# pick child to swap with
					array[hole] = array[child]
				else:
					break
				hole = child
			else:
				# Sort so biggest value is root
				# hole * 2 is left child, child + 1 is the right child
				child = hole * 2
				if (child != currentSize && array[child + 1][0] > array[child][0]):
					child += 1
				
				if (array[child][0] > tmp[0]):
					# pick child to swap with
					array[hole] = array[child]
				else:
					break
				hole = child
		array[hole] = tmp

	func percolate_up(hole):
		var tmp = array[hole]
		if (maintain_min):
			# Sort smallest value towards root
			while(hole > 1 && tmp[0] < array[hole / 2][0]):
				# Get parent node and push it below
				array[hole] = array[hole / 2]
				hole /= 2
		else:
			# Sort biggest value towards root
			while(hole > 1 && tmp[0] > array[hole / 2][0]):
				# Get parent node and push it below
				array[hole] = array[hole / 2]
				hole /= 2
		array[hole] = tmp

	func change_priority(arrayIdx, new_priority):
		# Changes priority of the item at arrayIdx to new_priority
		# If the new priority value is higher, this means the item was demoted, so we need to percolate down
		# If the new priority value is lower, the item has been promoted and needs to percolate up
		if (arrayIdx < 0 || arrayIdx + 1 > currentSize):
			# Invalid index for array. Abort
			print(str(OS.get_ticks_msec()) + ": PRIORITY QUEUE (" + str(get_instance_id()) + "): Can't access array at index '" + str(arrayIdx) + "', out of bounds!")
			return false
		if (typeof(new_priority) != TYPE_INT && typeof(new_priority) != TYPE_REAL):
			# Invalid priority parameter. Abort
			print(str(OS.get_ticks_msec()) + ": PRIORITY QUEUE (" + str(get_instance_id()) + "): Can't assign priority '" + str(new_priority) + "', NaN!")
			return false

		var node = array[arrayIdx + 1]
		if (maintain_min):
			# Sort smallest value towards root
			if (new_priority < node[0] ):
				# Item was promoted, move it ahead in the queue
				node[0] = new_priority
				percolate_up(arrayIdx + 1)
				return true
			elif (new_priority > node[0]):
				# Item was demoted, move it back in the queue
				node[0] = new_priority
				percolate_down(arrayIdx + 1)
				return true
		else:
			# Sort highest value towards root
			if (new_priority > node[0] ):
				# Item was promoted, move it ahead in the queue
				node[0] = new_priority
				percolate_up(arrayIdx + 1)
				return true
			elif (new_priority < node[0]):
				# Item was demoted, move it back in the queue
				node[0] = new_priority
				percolate_down(arrayIdx + 1)
				return true
		# Implied else: do nothing, priority hasn't changed
		return true

	func remove_and_collide(arrayIdx):
		# First, promote item to the top
		# Then remove_min
		# This removes the item from the tree
		# priority must be higher than the one at root
		if (arrayIdx + 1 > currentSize || arrayIdx < 0):
			print(str(OS.get_ticks_msec()) + ": PRIORITY QUEUE (" + str(get_instance_id()) + "): remove_and_collide(arrayIdx) out of bounds! arrayIdx = " + str(arrayIdx) + ", currentSize = " + str(currentSize))
			return null
		var prio
		if (maintain_min):
			prio = get_root_priority() - 1 # All cases except integer underflow caught
		else:
			prio = get_root_priority() + 1 # All cases except integer overflow
		change_priority(arrayIdx, prio)
		var root = remove_root()
		return root

	func merge_with(priority_queue, set_maintain_min = true):
		# Put items of both queues into a new list
		# Create new queue with those items and return that queue
		var list = []
		var own_queue = get_queue()
		var other_queue = priority_queue.get_queue()
		# Loop through own entries
		var length_own = own_queue.size() - 1
		var length_other = other_queue.size() - 1
		var i = max(length_own, length_other)
		while (i >= 0):
			if (i < length_own):
				if (own_queue[i] != null):
					list.append(own_queue[i])
			if (i < length_other):
				if (other_queue[i] != null):
					list.append(other_queue[i])
			i -= 1
		var queue = DS.PriorityQueue.new(list, set_maintain_min)
		return queue
