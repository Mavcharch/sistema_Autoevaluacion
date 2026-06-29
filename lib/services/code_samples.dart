import '../models/programming_language.dart';

/// Ejemplos de código precargados para que el usuario pruebe la app.
class CodeSamples {
  CodeSamples._();

  static const Map<ProgrammingLanguage, String> samples = {
    ProgrammingLanguage.python: '''def bubble_sort(arr):
    n = len(arr)
    for i in range(n):
        for j in range(0, n - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
    return arr

def find_pair(arr, target):
    for i in range(len(arr)):
        for j in range(i + 1, len(arr)):
            if arr[i] + arr[j] == target:
                return [i, j]
    return []

result = bubble_sort([5, 2, 9, 1, 5, 6])
print(result)
''',
    ProgrammingLanguage.javascript: '''function findDuplicates(nums) {
  const result = [];
  for (let i = 0; i < nums.length; i++) {
    for (let j = i + 1; j < nums.length; j++) {
      if (nums[i] == nums[j] && !result.indexOf(nums[i])) {
        result.push(nums[i]);
      }
    }
  }
  return result;
}

function fibonacci(n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

console.log(findDuplicates([1, 2, 3, 2, 4, 3, 5]));
console.log(fibonacci(10));
''',
    ProgrammingLanguage.java: '''public class Calculator {

    public int factorial(int n) {
        if (n < 0) {
            return 0;
        }
        int result = 1;
        for (int i = 2; i <= n; i++) {
            result = result * i;
        }
        return result;
    }

    public boolean isPrime(int number) {
        if (number < 2) {
            return false;
        }
        for (int i = 2; i < number; i++) {
            if (number % i == 0) {
                return false;
            }
        }
        return true;
    }
}
''',
    ProgrammingLanguage.cpp: '''#include <iostream>
using namespace std;

int linearSearch(int arr[], int size, int target) {
    for (int i = 0; i < size; i++) {
        if (arr[i] == target) {
            return i;
        }
    }
    return -1;
}

void printAllPairs(int arr[], int n) {
    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            cout << arr[i] << "," << arr[j] << endl;
        }
    }
}

int main() {
    int arr[] = {5, 3, 8, 1, 9};
    cout << linearSearch(arr, 5, 8) << endl;
    printAllPairs(arr, 5);
    return 0;
}
''',
    ProgrammingLanguage.dart: '''List<int> mergeSortedLists(List<int> a, List<int> b) {
  final result = <int>[];
  int i = 0;
  int j = 0;
  while (i < a.length && j < b.length) {
    if (a[i] <= b[j]) {
      result.add(a[i]);
      i++;
    } else {
      result.add(b[j]);
      j++;
    }
  }
  while (i < a.length) {
    result.add(a[i]);
    i++;
  }
  while (j < b.length) {
    result.add(b[j]);
    j++;
  }
  return result;
}

void main() {
  print(mergeSortedLists([1, 3, 5], [2, 4, 6]));
}
''',
  };

  static String? sampleFor(ProgrammingLanguage language) => samples[language];
}
