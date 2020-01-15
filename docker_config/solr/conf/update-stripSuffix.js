/*
  Script for stripping a suffix from a field.

  This script should be called with two params:

  - field: the field to strip the suffix from
  - suffix: the suffix to remove

  In order for this to be executed, it must be properly wired into solrconfig.xml; by default it is commented out in
  the example solrconfig.xml and must be uncommented to be enabled.

  See http://wiki.apache.org/solr/ScriptUpdateProcessor for more details.
*/

if (!String.prototype.includes) {
  String.prototype.includes = function() {'use strict';
    return String.prototype.indexOf.apply(this, arguments) !== -1;
  };
}


function processAdd(cmd) {
  var doc = cmd.solrDoc;  // org.apache.solr.common.SolrInputDocument
  var id = doc.getFieldValue("id");

  logger.debug("update-script#processAdd: id=" + id);
  logger.debug("update-script#processAdd: keys=" + doc.keySet());

  var field = params.get('field')
  var suffix = params.get('suffix');

  logger.debug("update-script#processAdd: field=" + field);
  logger.debug("update-script#processAdd: suffix=" + suffix);

  // var field = "title"
  // var suffix = " | UMD Libraries";

  stripSuffixFromField(doc, field, suffix);

  logger.debug("update-script#processAdd: updated keys=" + doc.keySet());
}

function processDelete(cmd) {
  // no-op
}

function processMergeIndexes(cmd) {
  // no-op
}

function processCommit(cmd) {
  // no-op
}

function processRollback(cmd) {
  // no-op
}

function finish() {
  // no-op
}

// Reduce RDF URI to namespace prefixes Type based on rdf_type
function stripSuffixFromField(doc, field, suffix) {
  if (doc.containsKey(field)) {
    var fieldValue = doc.getFieldValue(field);
    doc.remove(field);
    var stripped_title = stripSuffix(fieldValue, suffix);
    doc.addField(field, stripped_title);
  }
}

// Returns the given string with the given suffix removed.
function stripSuffix(str, suffix) {
  var trimmedStr = str.trim();
  if (trimmedStr.endsWith(suffix)) {
    var endIndex = trimmedStr.length - suffix.length
    return trimmedStr.substring(0, endIndex).trim();
  }

  return str;
}
