# Ensembl module for Bio::EnsEMBL::Analysis::Config::GeneBuild::TranscriptCoalescer
#
# Copyright (c) 2004 Ensembl
#


=head1 NAME

Bio::EnsEMBL::Analysis::Config::GeneBuild::TranscriptCoalescer

=head1 SYNOPSIS

    Bio::EnsEMBL::Analysis::Config::GeneBuild::TranscriptCoalescer ; 
    Bio::EnsEMBL::Analysis::Config::GeneBuild::TranscriptCoalescer qw () ; 

=head1 DESCRIPTION


TranscriptCoalescer-Configuration 

This is the main configuration file for TranscriptCoalescer, a perl 
module which coalesces genes of different sources (EST-genes are 
combined with other EST-genes and Similarity-Genewise-genes or 
ab-initio-predictions (i.e. fgenesh, Genscan, GeneFinder ...) . 

TranscriptCoalescer fetches genes and prediction_transcripts by it's 
biotype (for Bio::EnsEMBL::Gene-objects) and by it's logic_name 
(for Bio::EnsEMBL::PredictionTranscript-objects). These biotypes/
logic_names are defiend in this configuration-file. Each biotype/
logic_name has to belong to a different evidence_set. (see below).

The parameters to connect to various databases are defiend in 

  - modules/Bio/EnsEMBL/Analysis/Config/GeneBuild/Databases.pm 
  - modules/Bio/EnsEMBL/Analysis/Config/Exonerate2Genes.pm  

The general function of this config file is to import  a number of 
standard global variables into the calling package. Without arguments 
all the standard variables are set, and with a list, only those variables 
whose names are provided are set.  The module will die if a variable 
which doesn\'t appear in its C<%Config> hash is asked to be set.

The variables can also be references to arrays or hashes.

Edit C<%Config> to add or alter variables.

All the variables are in capitals, so that they resemble environment
variables.

=head1 CONTACT

B<ensembl-dev@ebi.ac.uk>

=cut

package Bio::EnsEMBL::Analysis::Config::GeneBuild::TranscriptCoalescer;

use strict;
use vars qw(%Config);

%Config= 
 (

  NEW_BIOTYPE => 'Coalescer',  # Biotype of genes which will be written to COALESCER_DB


  # The runnable includes a filtering proceudure which removes partial transcripts 
  # if they are overlapped by a longer transcript. These transcripts have a different 
  # biotype than the ones which passed the filter. Their biotype begins with "del_". 
  # If you want to write these filtered genes as well you ave to set 
  # WRITE_FILTERED_TRANSCRIPTS to true / 1 
  #
  WRITE_FILTERED_TRANSCRIPTS => '1'  , 
  WRITE_ALTERNATIVE_TRANSCRIPTS => '1'  ,  # these tr have simgw source 

  # use build-in rules to decide if simgw is better than est or other way around. 
  # if set to '0', only the EST combined genes are written 
  # THIS IS CURRENTLY NOT IMPLEMENTD 
  ADJUDICATE_SIMGW_EST => '0',  
  
  MIN_TRANSLATION_LENGTH => 50,   

  VERBOSE => 0 , 

  #
  # If you need to configure additional databases, add them to Databases.pm and use
  # a differnt "database_class" (e.g. EXONERATE_2_DB). You have to add another entry
  # in this file as well (Don't forget to use the same database_class-name !)  
  #
 
  
   TRANSCRIPT_COLAESCER_DB_CONFIG => { 
                 # add the logic_names of the ab-inito-predictions you like to 
                 # use for TranscriptCoalescer.pm here 
                 
                 REFERENCE_DB => { 
                                  BIOTYPES              => [],   
                                  AB_INITIO_LOGICNAMES  => [] ,
                                 }, 


                 # add the biotypes of your targetted / similarity-genees here. 
                 # These genes are fetched out of GENEWISE_DB specified in Databases.pm 

                 GENEWISE_DB => { 
                                  BIOTYPES              => ['best_non_consensus','consensus','longest_non_consensus','sim_85'],   
                                  AB_INITIO_LOGICNAMES  => [],  
                                 }, 


                 # add the biotypes of your cdna/est-genes made by exonerate here 
                 # These genes are fetched out of EXONERATE_DB specified in Databases.pm 


                 EXONERATE_DB => { 
                                  BIOTYPES              => ['est_exonerate'],   
                                  AB_INITIO_LOGICNAMES            => [],  
                                 }, 

                   
                  },
 
                  #
                  # ASSIGNING THE DIFFERENT BIOTYPES AND LOGIC-NAMES TO EVIDENCE-SETS 
                  # 
                  # There are currently 3 different evidence-sets supported : 
                  # - EST_SETS, 
                  # - SIMGW_SETS 
                  # - ABINITIO_SETS
                  #
                  # Put the biotypes for Bio::EnsEMBL::Gene objects in the set.
                  # For Bio::EnsEMBL::PredictionTranscripts use the logic_name
                  #
                  
                  EST_SETS      =>['est_exonerate'], 
                  SIMGW_SETS    =>['best_non_consensus','consensus','longest_non_consensus','sim_85'],   
                  ABINITIO_SETS =>[] , 
 
             );


sub import {
    my ($callpack) = caller(0); # Name of the calling package
    my $pack = shift; # Need to move package off @_

    # Get list of variables supplied, or else all
    my @vars = @_ ? @_ : keys(%Config);
    return unless @vars;

    # Predeclare global variables in calling package
    eval "package $callpack; use vars qw("
         . join(' ', map { '$'.$_ } @vars) . ")";
    die $@ if $@;


    foreach (@vars) {
	if (defined $Config{ $_ }) {
            no strict 'refs';
	    # Exporter does a similar job to the following
	    # statement, but for function names, not
	    # scalar variables:
	    *{"${callpack}::$_"} = \$Config{ $_ };
	} else {
	    die "Error: Config: $_ not known\n";
	}
    }
}

1;
