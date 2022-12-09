import sys


def main():
    m = [[int(c) for c in l] for l in [l.strip() for l in sys.stdin] for c in l.split()]
    vs = []
    ss = []
    for i, r in enumerate(m):
        for j, h in enumerate(r):
            w = r[:j]
            e = r[j + 1:] 
            n = [rt[j] for rt in m[:i]]
            s = [rb[j] for rb in m[i + 1: ]]
            if any([all(t < h for t in w), all(t < h for t  in e), all(t < h for t in n), all(t < h for t in s)]):
                vs.append((i, j))
            ss.append(dist(h, reversed(w)) * dist(h, e) * dist(h, reversed(n)) * dist(h, s))
    print(len(vs))
    print(max(ss))


def dist(h, l):
    d = 0
    for t in l:
        d += 1
        if t >= h:
            break
    return d


if '__main__' == __name__:
    main()