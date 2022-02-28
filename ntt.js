const paramsQ = 3329;
const paramsQinv = 62209;
const zetas = [
    2285, 2571, 2970, 1812, 1493, 1422, 287, 202, 3158, 622, 1577, 182, 962,
    2127, 1855, 1468, 573, 2004, 264, 383, 2500, 1458, 1727, 3199, 2648, 1017,
    732, 608, 1787, 411, 3124, 1758, 1223, 652, 2777, 1015, 2036, 1491, 3047,
    1785, 516, 3321, 3009, 2663, 1711, 2167, 126, 1469, 2476, 3239, 3058, 830,
    107, 1908, 3082, 2378, 2931, 961, 1821, 2604, 448, 2264, 677, 2054, 2226,
    430, 555, 843, 2078, 871, 1550, 105, 422, 587, 177, 3094, 3038, 2869, 1574,
    1653, 3083, 778, 1159, 3182, 2552, 1483, 2727, 1119, 1739, 644, 2457, 349,
    418, 329, 3173, 3254, 817, 1097, 603, 610, 1322, 2044, 1864, 384, 2114, 3193,
    1218, 1994, 2455, 220, 2142, 1670, 2144, 1799, 2051, 794, 1819, 2475, 2459,
    478, 3221, 3021, 996, 991, 958, 1869, 1522, 1628];

const zetasInverse = [
    1701, 1807, 1460, 2371, 2338, 2333, 308, 108, 2851, 870, 854, 1510, 2535,
    1278, 1530, 1185, 1659, 1187, 3109, 874, 1335, 2111, 136, 1215, 2945, 1465,
    1285, 2007, 2719, 2726, 2232, 2512, 75, 156, 3000, 2911, 2980, 872, 2685,
    1590, 2210, 602, 1846, 777, 147, 2170, 2551, 246, 1676, 1755, 460, 291, 235,
    3152, 2742, 2907, 3224, 1779, 2458, 1251, 2486, 2774, 2899, 1103, 1275, 2652,
    1065, 2881, 725, 1508, 2368, 398, 951, 247, 1421, 3222, 2499, 271, 90, 853,
    1860, 3203, 1162, 1618, 666, 320, 8, 2813, 1544, 282, 1838, 1293, 2314, 552,
    2677, 2106, 1571, 205, 2918, 1542, 2721, 2597, 2312, 681, 130, 1602, 1871,
    829, 2946, 3065, 1325, 2756, 1861, 1474, 1202, 2367, 3147, 1752, 2707, 171,
    3127, 3042, 1907, 1836, 1517, 359, 758, 1441];

function montgomeryReduce(a) {
    let u = int16(int32(a) * paramsQinv);
    let t = u * paramsQ;
    t = a - t;
    t >>= 16;
    return int16(t);
}

function int16(n) {
    let end = -32768;
    let start = 32767;

    if (n >= end && n <= start) {
        return n;
    }
    if (n < end) {
        n = n + 32769;
        n = n % 65536;
        n = start + n;
        return n;
    }
    if (n > start) {
        n = n - 32768;
        n = n % 65536;
        n = end + n;
        return n;
    }
}

function int32(n) {
    let end = -2147483648;
    let start = 2147483647;

    if (n >= end && n <= start) {
        return n;
    }
    if (n < end) {
        n = n + 2147483649;
        n = n % 4294967296;
        n = start + n;
        return n;
    }
    if (n > start) {
        n = n - 2147483648;
        n = n % 4294967296;
        n = end + n;
        return n;
    }
}

function computeBarrett(a) {
    let v = ((1 << 24) + paramsQ / 2) / paramsQ;
    let t = v * a >> 24;
    t = t * paramsQ;
    return a - t;
}

function ntt(r) {
    let list = Array.from(r);
    let j = 0;
    let k = 1;
    for (let l = 128; l >= 2; l >>= 1) {
        for (let start = 0; start < 256; start = j + l) {
            let zeta = zetas[k];
            k = k + 1;
            for (j = start; j < start + l; j++) {
                let t = montgomeryReduce(zeta * list[j + l]);
                list[j + l] = list[j] - t;
                list[j] = list[j] + t;

            }
        }
    }
    return list;
}

function nttInverse(r) {
    let list = Array.from(r);
    let j = 0;
    let k = 0;
    for (let l = 2; l <= 128; l <<= 1) {
        for (let start = 0; start < 256; start = j + l) {
            let zeta = zetasInverse[k];
            k = k + 1;
            for (j = start; j < start + l; j++) {
                let t = list[j];
                list[j] = computeBarrett(t + list[j + l]);
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

function test() {
    let list = [];
    for (let i = 0; i < 256; i++) {
        list.push(i);
    }
    let nttResult = ntt(list);
    let nttInverse1 = nttInverse(list);
    let nttInverse2 = nttInverse(nttResult);
    let fs = require('fs');
    fs.writeFileSync('js_ntt.json', JSON.stringify({
        'ntt': nttResult,
        'nttInverse1': nttInverse1,
        'nttInverse2': nttInverse2
    }))
    if (fs.existsSync('dart_ntt.json')) {
        let content = fs.readFileSync('dart_ntt.json', 'utf8');
        let values = JSON.parse(content)
        let nttFailure = false;
        let nttInverse1Failure = false;
        let nttInverse2Failure = false;
        let nttFails = [];
        let nttInverse1Fails = [];
        let nttInverse2Fails = [];
        for (let i = 0; i < nttResult.length; i++) {
            if (values.ntt[i] !== nttResult[i]) {
                nttFailure = true;
                nttFails.push(i);
            }
            if (values.nttInverse1[i] !== nttInverse1[i]) {
                nttInverse1Failure = true;
                nttInverse1Fails.push(i);
            }
            if(values.nttInverse2[i] !== nttInverse2[i]) {
                nttInverse2Failure = true;
                nttInverse2Fails.push(i);
            }
        }
        if (nttFailure) {
            console.log('NTT fails at indices ' + JSON.stringify(nttFails))
        }
        if(nttInverse1Failure) {
            console.log('NTT Inverse 1 fails at indices ' + JSON.stringify(nttInverse1Fails))
        }
        if(nttInverse2Failure) {
            console.log('NTT Inverse 2 fails at indices ' + JSON.stringify(nttInverse2Fails))
        }
    }
}

test()