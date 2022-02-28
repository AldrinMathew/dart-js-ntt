import 'dart:convert';
import 'dart:io';

const int paramsQ = 3329;
const int paramsQInverse = 62209;

int montgomeryReduce(int value) {
  int u = int16(int32(value) * paramsQInverse);
  int t = u * paramsQ;
  t = value - t;
  t >>= 16;
  return int16(t);
}

int int32(int value) {
  int end = -2147483648;
  int start = 2147483647;

  if (value >= end && value <= start) {
    return value;
  } else if (value < end) {
    value = value + 2147483649;
    value = value % 4294967296;
    value = start + value;
    return value;
  } else if (value > start) {
    value = value - 2147483648;
    value = value % 4294967296;
    value = end + value;
    return value;
  } else {
    return value;
  }
}

int int16(int value) {
  int end = -32768;
  int start = 32767;
  if (value >= end && value <= start) {
    return value;
  } else if (value < end) {
    value = value + 32769;
    value = value % 65536;
    value = start + value;
    return value;
  } else if (value > start) {
    value = value - 32768;
    value = value % 65536;
    value = end + value;
    return value;
  } else {
    return value;
  }
}

int computeBarret(int value) {
  num newVal = (((1 << 24) + paramsQ / 2) / paramsQ);
  int t = (newVal * value).truncate() >> 24;
  t = t * paramsQ;
  return value - t;
}

List<int> ntt(List<int> values) {
  var list = List<int>.from(values);
  int j = 0, k = 1;
  for (int l = 128; l >= 2; l >>= 1) {
    for (int start = 0; start < 256; start = j + l) {
      int zeta = zetas[k];
      k = k + 1;
      for (j = start; j < (start + l); j++) {
        int t = montgomeryReduce(zeta * list[j + l]);
        list[j + l] = int16(list[j] - t);
        list[j] = int16(list[j] + t);
      }
    }
  }
  return list;
}

List<int> nttInverse(List<int> values) {
  List<int> list = List.from(values);
  int j = 0, k = 0, zeta = 0, t = 0;
  for (int l = 2; l <= 128; l <<= 1) {
    for (int start = 0; start < 256; start = j + l) {
      zeta = zetasInverse[k];
      k++;
      for (j = start; j < start + l; j++) {
        t = list[j];
        list[j] = computeBarret(t + list[j + l]);
        list[j + l] = t - list[j + l];
        list[j + l] = montgomeryReduce(zeta * list[j + l]);
      }
    }
  }
  for (j = 0; j < 256; j++) {
    list[j] = montgomeryReduce(list[j] * zetasInverse[127]);
  }
  return list;
}

const List<int> zetas = [
  2285,
  2571,
  2970,
  1812,
  1493,
  1422,
  287,
  202,
  3158,
  622,
  1577,
  182,
  962,
  2127,
  1855,
  1468,
  573,
  2004,
  264,
  383,
  2500,
  1458,
  1727,
  3199,
  2648,
  1017,
  732,
  608,
  1787,
  411,
  3124,
  1758,
  1223,
  652,
  2777,
  1015,
  2036,
  1491,
  3047,
  1785,
  516,
  3321,
  3009,
  2663,
  1711,
  2167,
  126,
  1469,
  2476,
  3239,
  3058,
  830,
  107,
  1908,
  3082,
  2378,
  2931,
  961,
  1821,
  2604,
  448,
  2264,
  677,
  2054,
  2226,
  430,
  555,
  843,
  2078,
  871,
  1550,
  105,
  422,
  587,
  177,
  3094,
  3038,
  2869,
  1574,
  1653,
  3083,
  778,
  1159,
  3182,
  2552,
  1483,
  2727,
  1119,
  1739,
  644,
  2457,
  349,
  418,
  329,
  3173,
  3254,
  817,
  1097,
  603,
  610,
  1322,
  2044,
  1864,
  384,
  2114,
  3193,
  1218,
  1994,
  2455,
  220,
  2142,
  1670,
  2144,
  1799,
  2051,
  794,
  1819,
  2475,
  2459,
  478,
  3221,
  3021,
  996,
  991,
  958,
  1869,
  1522,
  1628
];

const List<int> zetasInverse = [
  1701,
  1807,
  1460,
  2371,
  2338,
  2333,
  308,
  108,
  2851,
  870,
  854,
  1510,
  2535,
  1278,
  1530,
  1185,
  1659,
  1187,
  3109,
  874,
  1335,
  2111,
  136,
  1215,
  2945,
  1465,
  1285,
  2007,
  2719,
  2726,
  2232,
  2512,
  75,
  156,
  3000,
  2911,
  2980,
  872,
  2685,
  1590,
  2210,
  602,
  1846,
  777,
  147,
  2170,
  2551,
  246,
  1676,
  1755,
  460,
  291,
  235,
  3152,
  2742,
  2907,
  3224,
  1779,
  2458,
  1251,
  2486,
  2774,
  2899,
  1103,
  1275,
  2652,
  1065,
  2881,
  725,
  1508,
  2368,
  398,
  951,
  247,
  1421,
  3222,
  2499,
  271,
  90,
  853,
  1860,
  3203,
  1162,
  1618,
  666,
  320,
  8,
  2813,
  1544,
  282,
  1838,
  1293,
  2314,
  552,
  2677,
  2106,
  1571,
  205,
  2918,
  1542,
  2721,
  2597,
  2312,
  681,
  130,
  1602,
  1871,
  829,
  2946,
  3065,
  1325,
  2756,
  1861,
  1474,
  1202,
  2367,
  3147,
  1752,
  2707,
  171,
  3127,
  3042,
  1907,
  1836,
  1517,
  359,
  758,
  1441
];

void main() {
  var list = List.generate(256, (index) => index);
  var nttResult = ntt(list);
  var nttInverse1 = nttInverse(list);
  var nttInverse2 = nttInverse(nttResult);
  var output = File('dart_ntt.json');
  Map<String, List<int>> results = {
    'ntt': nttResult,
    'nttInverse1': nttInverse1,
    'nttInverse2': nttInverse2,
  };
  output.writeAsStringSync(jsonEncode(results), mode: FileMode.write);

  var jsNtt = File('js_ntt.json');
  if (jsNtt.existsSync()) {
    var content = jsNtt.readAsStringSync();
    var values = jsonDecode(content);
    var nttFailure = false;
    var nttInverse1Failure = false;
    var nttInverse2Failure = false;
    var nttFails = [];
    var nttInverse1Fails = [];
    var nttInverse2Fails = [];
    for (var i = 0; i < nttResult.length; i++) {
      if (values['ntt'][i] != nttResult[i]) {
        nttFailure = true;
        nttFails.add(i);
      }
      if (values['nttInverse1'][i] != nttInverse1[i]) {
        nttInverse1Failure = true;
        nttInverse1Fails.add(i);
      }
      if (values['nttInverse2'][i] != nttInverse2[i]) {
        nttInverse2Failure = true;
        nttInverse2Fails.add(i);
      }
    }
    if (nttFailure) {
      print('NTT fails at indices ' + nttFails.toString());
    }
    if (nttInverse1Failure) {
      print('NTT Inverse 1 fails at indices ' + nttInverse1Fails.toString());
    }
    if (nttInverse2Failure) {
      print('NTT Inverse 2 fails at indices ' + nttInverse2Fails.toString());
    }
  }
}
