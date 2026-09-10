import 'package:flutter_test/flutter_test.dart';
import 'package:localgo/core/utils/fuzzy_search.dart';

void main() {
  const electrician =
      'Sharma Electricals electrician Wiring, fan & inverter repair, meter problem Certified electrician';
  const plumber =
      'Kumar Plumbing & Pipes plumber Tap leakage, tank cleaning, pipe fitting';
  const painter = 'Rangrej Painting Co. painter Room painting, putty, waterproofing';

  test('prefix matching: "ele" finds electricians', () {
    expect(FuzzySearch.matches('ele', electrician), isTrue);
    expect(FuzzySearch.matches('ele', plumber), isFalse);
  });

  test('typo tolerance: misspelled words still match', () {
    expect(FuzzySearch.matches('elecrician', electrician), isTrue); // missing t
    expect(FuzzySearch.matches('electrican', electrician), isTrue); // missing i
    expect(FuzzySearch.matches('plumer', plumber), isTrue); // missing b
    expect(FuzzySearch.matches('paintar', painter), isTrue); // a for e
  });

  test('plain substring matching works', () {
    expect(FuzzySearch.matches('wiring', electrician), isTrue);
    expect(FuzzySearch.matches('AC service',
        'Mister Singh AC Care ac-fridge AC service, gas refill, fridge repair'),
      isTrue);
  });

  test('multi-word queries require every word to match', () {
    expect(FuzzySearch.matches('ac gas', 'AC service, gas refill'), isTrue);
    expect(FuzzySearch.matches('ac plumbing', 'AC service, gas refill'), isFalse);
  });

  test('empty query matches everything', () {
    expect(FuzzySearch.matches('', electrician), isTrue);
  });

  test('unrelated query does not match', () {
    expect(FuzzySearch.matches('lawyer', electrician), isFalse);
  });
}
