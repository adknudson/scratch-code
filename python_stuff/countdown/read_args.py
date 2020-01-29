import argparse
import itertools
from sympy.utilities.iterables import kbins, multiset_permutations, iproduct
import operator as op


operations = {'+': op.add, 
              '-': op.sub,
              '*': op.mul,
              '/': op.truediv}


def is_integer(x):
    return float.is_integer(float(x))


def f(S):
    N = len(S)
    if N == 1:
        return S
    elif N == 2:
        return [tuple(x) for x in multiset_permutations(S, 2)]
    else:
        accumulator = []
        for p in kbins(S, 2, ordered=10):
            accumulator.extend(iproduct(f(p[0]), f(p[1])))
        return accumulator
    
    
def unpackFactorGroup(factoredGroup, operations):
    left, right = factoredGroup[0], factoredGroup[1]
    F = list(operations)  # Operations get passed as tuple. Need to be a list

    # CASE 1: Left and Right are tuples
    if type(left) is tuple and type(right) is tuple:
        fx = F.pop()
        format_left = unpackFactorGroup(left, F)
        F.pop()
        format_right = unpackFactorGroup(right, F)
        return F"({format_left}) {fx} ({format_right})"

    # CASE 2: Left is a tuple and the Right is not a tuple
    elif type(left) is tuple and type(right) is not tuple:
        try:
            fx = F.pop()
        except:
            fx = F
        return F"({unpackFactorGroup(left, F)} {fx} {right})"

    # CASE 3: Left is not a tuple and the Right is a tuple
    elif type(left) is not tuple and type(right) is tuple:
        try:
            fx = F.pop()
        except:
            fx = F
        return F"({left} {fx} {unpackFactorGroup(right, F)})"

    # CASE 4: Neither Left nor Right is a tuple
    elif type(left) is not tuple and type(right) is not tuple:
        try:
            fx = F.pop()
        except:
            fx = F
        return F"({left} {fx} {right})"
    
    # CASE 5: WTF
    else:
        raise ValueError()

    
def allIntegerResults(numberSet, operations):
    results = {}
    N = len(numberSet)

    # All groups of size 2 up to N
    for n_elements in range(2, N+1):
        # Get all combinations of n elements C(N, n)
        # Treat each combination as a new 'hand'
        combinationSet = itertools.combinations(numberSet, n_elements)
        # for a hand of size n, there are n-1 operations
        operationSet = list(itertools.product(operations, repeat=n_elements-1))
        # For each hand, find the two element factor groups
        for hand in combinationSet:
            # Go through every two element factor group
            for factorGroup in f(hand):
                # Go through every combination of operations
                for operationCombination in operationSet:
                    result = unpackFactorGroup(
                        factoredGroup=factorGroup,
                        operations=operationCombination)

                    try:
                        eval(result)
                    except (TypeError, ZeroDivisionError):
                        pass
                    else:
                        eval_result = eval(result)

                    if is_integer(eval_result):
                        # Add the combination to the results
                        # If the number is already a key in the results, then
                        # append the combo to the values
                        if int(eval_result) in results:
                            results[int(eval_result)].append(result)
                        # If the key does not exist, add it to the results
                        else:
                            results[int(eval_result)] = [result]
                    else:
                        pass
    return results


parser = argparse.ArgumentParser(description='Read in some integers and do some math.')
parser.add_argument('integers', metavar='N', type=int, nargs='+',
                    help='A list of integers to operate on')


if __name__=="__main__":
    args = parser.parse_args()
    air = allIntegerResults(args.integers, operations)
    print(air)