#!/usr/bin/env python3

# Got the data from below
# https://instancetyp.es/

import json
import sys

def listInstanceTypeSortByMonth(data):
    releaseDate_set = set()
    for instance in data['instances']:
        release_year = str(instance['release_year'])
        release_month = str(instance['release_month'])
        release_date = release_year + '/' + release_month
        if not release_date in releaseDate_set:
            print('\n' + release_date)
        print(instance['instance_type'])
        releaseDate_set.add(release_date)

def listInstanceType(data):
    for instance in data['instances']:
        instance_type = instance['instance_type']
        print(instance_type)

def listreleaseDate(data):
    convertDate = {
        'January': 1,
        'February': 2,
        'March': 3,
        'April': 4,
        'May': 5,
        'June': 6,
        'July': 7,
        'August': 8,
        'September': 9,
        'October': 10,
        'November': 11,
        'December': 12
    }
    releaseDate_set = set()
    for instance in data['instances']:
        release_year = str(instance['release_year'])
        release_month = str(convertDate[instance['release_month']])
        release_date = release_year + '/' + release_month
        if not release_date in releaseDate_set:
            print(release_date)
        releaseDate_set.add(release_date)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('./timeline.py <timeline json file name>')
        sys.exit(1)
    with open(sys.argv[1], 'r') as f:
        data = json.load(f)
    listreleaseDate(data)
    #listInstanceType(data)
    #listInstanceTypeSortByMonth(data)
