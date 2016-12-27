# elasticSearch-2-x-to-5-x
Ruby script converts index (settings, mapping, aliases (optionally)) from ES v 2.x to ES v 5.x

You can define:
- url elasticSearch (from, to)
- old name of index (ES v 2.x) and new name of index (ES v 5.x) -> to new name of index is add automatic creation date so new index is name newName_YYYYMMDDHHMMSS
- convert mapping / settings / aliases (optionally) 
- can create settings / mappings / aliases like .json
