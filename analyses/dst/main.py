CASQUETS = [
    {
        'latitude': '50°02’.65 N ',
        'longitude': '002°57’.01 W'
    },
    {
        'latitude': '50°07’.70 N',
        'longitude': '002°27’.81 W'
    },
    {
        'latitude': '49°51’.80 N',
        'longitude': '002°21’.24 W'
    },
    {
        'latitude': '49°46’.80 N',
        'longitude': '002°50’.41 W'
    }
]

OUESSANT = [
    {
        'latitude': '48°42’.60 N',
        'longitude': '006°02’.80 W'
    },
    {
        'latitude': '48°56’.40 N',
        'longitude': '005°51’.60 W'
    },
    {
        'latitude': '49°02’.00 N',
        'longitude': '005°36’.80 W'
    },
    {
        'latitude': '48°37’.20 N',
        'longitude': '005°11’.90 W'
    },
    {
        'latitude': '48°29’.39 N',
        'longitude': '005°22’.05 W'
    }
]

DOVER = [
    {
        'latitude': '51°33’.66 N',
        'longitude': '002°02’.17 E'
    },
    {
        'latitude': '51°27’.35 N',
        'longitude': '001°52’.76 E'
    },
    {
        'latitude': '51°14’.13 N',
        'longitude': '001°43’.99 E'
    },
    {
        'latitude': '50°52’.47 N',
        'longitude': '001°02’.45 E'
    },
    {
        'latitude': '50°39’.37 N',
        'longitude': '000°32’.50 E'
    },
    {
        'latitude': '50°34’.64 N',
        'longitude': '000°04’.29 W'
    },
    {
        'latitude': '50°14’.49 N',
        'longitude': '000°04’.11 E'
    },
    {
        'latitude': '50°26’.37 N',
        'longitude': '001°00’.20 E'
    },
    {
        'latitude': '50°39’.29 N',
        'longitude': '001°22’.63 E'
    },
    {
        'latitude': '50°39’.49 N',
        'longitude': '001°22’.40 E'
    },
    {
        'latitude': '50°44’.54 N',
        'longitude': '001°26’.90 E'
    },
    {
        'latitude': '50°53’.64 N',
        'longitude': '001°30’.70 E'
    },
    {
        'latitude': '51°04’.34 N',
        'longitude': '001°45’.89 E'
    },
    {
        'latitude': '51°09’.84 N',
        'longitude': '002°03’.12 E'
    },
    {
        'latitude': '51°05’.77 N',
        'longitude': '001°38’.65 E'
    },
    {
        'latitude': '51°26’.97 N',
        'longitude': '002°16’.95 E'
    }
]

CORSE = [
    {
        'latitude': '43°02’.00 N',
        'longitude': '09°40’.00 E'
    },
    {
        'latitude': '42°48’.00 N',
        'longitude': '009°45’.40 E'
    },
    {
        'latitude': '42°48’.00 N',
        'longitude': '009°36’.50 E'
    },
    {
        'latitude': '42°54’.00 N',
        'longitude': '009°35’.02 E'
    },
    {
        'latitude': '43°02’.00 N',
        'longitude': '009°33’.40 E'
    },
    {
        'latitude': '43°07’.00 N',
        'longitude': '009°27’.20 E'
    },
    {
        'latitude': '43°07’.00 N',
        'longitude': '009°41’.30 E'
    }
]

TSS = [
    ('OUESSANT', OUESSANT),
    ('CASQUETS', CASQUETS),
    ('DOVER', DOVER),
    ('CORSE', CORSE)
]

TEMPLATE = '''{{
  "type": "Polygon",
  "coordinates": [
    {list}
  ]
}}'''


def convert_point(data):
    def parts(el):
        array = el.strip().split('°')
        degrees, rest = float(array[0]), ''.join(array[1:])
        rest = float(rest.replace('’', '').split(' ')[0])
        res = round(abs(degrees + rest / 60), 6)
        if el.endswith('S') or el.endswith('W'):
            return -1 * res
        return res
    return parts(data['latitude']), parts(data['longitude'])

for name, tss in TSS:
    points = map(convert_point, tss)
    points = list(map(lambda e: [e[1], e[0]], points))
    points.append(points[0])

    print(name, TEMPLATE.format(list=str(points)))
