=head1 LICENSE

Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

package Hive_final_clade_conf;

use strict;
use warnings;
use feature 'say';
use Data::Dumper;

use base ('Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf');

use Bio::EnsEMBL::ApiVersion qw/software_version/;

sub default_options {
    my ($self) = @_;
    return {
        # inherit other stuff from the base class
        %{ $self->SUPER::default_options() },

######################################################
# Variable settings
######################################################

########################
# Misc setup info
########################
'farm_user_name' => 'fm2',
'genebuilder_id' => 42,
'enscode_root_dir' => '/nfs/users/nfs_f/fm2/enscode/',
'output_path' => '/lustre/scratch109/ensembl/fm2/hive_assembly_loading/final_assembly_loading_clade',
'ftp_link_file' => '/lustre/scratch109/ensembl/fm2/hive_assembly_loading/final_assembly_loading_clade/ftp_link_file.txt',
'repeatmasker_library' => 'primates',


########################
# Pipe and ref db info
########################
'pipeline_name' => 'final_clade_assembly',
'pipe_dbname' => 'fm2_final_clade_assembly_pipe',
'pipe_db_server' => 'genebuild12',
'reference_db_server' => 'genebuild13',
'user' => 'ensadmin',
'password' => 'ensembl',
'port' => 3306,
'driver' => 'mysql',


########################
# BLAST db paths
########################
'uniprot_blast_db_path' => '/data/blastdb/Ensembl/uniprot_2015_07/uniprot',
'vertrna_blast_db_path' => '/data/blastdb/Supported/EMBL/current/vertrna/embl_vertrna-1',
'unigene_blast_db_path' => '/data/blastdb/Ensembl/unigene/unigene',


######################################################
#
# Mostly constant settings
#
######################################################

########################
# Excutable paths
########################
'dust_path' => '/software/ensembl/genebuild/usrlocalensemblbin/tcdust',
'trf_path' => '/software/ensembl/genebuild/usrlocalensemblbin/trf',
'eponine_path' => '/software/jdk1.6.0_14/bin/java',
'firstef_path' => '/software/ensembl/genebuild/usrlocalensemblbin/firstef',
'cpg_path' => '/software/ensembl/genebuild/usrlocalensemblbin/cpg',
'trnascan_path' => '/software/ensembl/genebuild/usrlocalensemblbin/tRNAscan-SE',
'repeatmasker_path' => '/software/ensembl/bin/RepeatMasker_3_3_0/RepeatMasker',
'genscan_path' => '/software/ensembl/genebuild/usrlocalensemblbin/genscan',
'uniprot_blast_exe_path' => '/software/ensembl/genebuild/usrlocalensemblbin/wublastp',
'vertrna_blast_exe_path' => '/software/ensembl/genebuild/usrlocalensemblbin/wutblastn',
'unigene_blast_exe_path' => '/software/ensembl/genebuild/usrlocalensemblbin/wutblastn',


########################
# Misc setup info
########################
'repeatmasker_engine' => 'wublast',
'contigs_source' => 'ncbi',
'primary_assembly_dir_name' => 'Primary_Assembly',

########################
# db info
########################
'create_type' => 'core_only',
'pipeline_db' => {
  -host   => $self->o('pipe_db_server'),
  -port   => $self->o('port'),
  -user   => $self->o('user'),
  -pass   => $self->o('password'),
  -dbname => $self->o('pipe_dbname'),
  -driver => $self->o('driver'),
},

'reference_db' => {
  -host   => $self->o('reference_db_server'),
  -port   => $self->o('port'),
  -user   => $self->o('user'),
  -pass   => $self->o('password'),
},

'production_db' => {
  -host   => 'ens-staging1',
  -port   => 3306,
  -user   => 'ensro',
  -dbname => 'ensembl_production',
},

'taxonomy_db' => {
  -host   => 'ens-livemirror',
  -port   => 3306,
  -user   => 'ensro',
  -dbname => 'ncbi_taxonomy',
},


    };
}

sub pipeline_create_commands {
    my ($self) = @_;
    return [
    # inheriting database and hive tables' creation
      @{$self->SUPER::pipeline_create_commands},
    ];
}

sub hive_meta_table {
    my ($self) = @_;
    return {
            %{$self->SUPER::hive_meta_table},       # here we inherit anything from the base class

        'hive_use_param_stack'  => 1,           # switch on the new param_stack mechanism
    };
}

## See diagram for pipeline structure
sub pipeline_analyses {
    my ($self) = @_;

    return [

###############################################################################
#
# SETUP AND INPUT ID CREATION ANALYSES
#
###############################################################################

      {
        -logic_name => 'setup_assembly_loading_pipeline',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveSetupAssemblyPipeline',
        -parameters => {
                         repeatmasker_library => $self->o('repeatmasker_library'),
                         repeatmasker_engine => $self->o('repeatmasker_engine'),
                         repeatmasker_path => $self->o('repeatmasker_path'),

                         dust_path => $self->o('dust_path'),
                         trf_path => $self->o('trf_path'),
                         eponine_path => $self->o('eponine_path'),
                         firstef_path => $self->o('firstef_path'),
                         cpg_path => $self->o('cpg_path'),
                         trnascan_path => $self->o('trnascan_path'),

                         uniprot_blast_db_path => $self->o('uniprot_blast_db_path'),
                         vertrna_blast_db_path => $self->o('vertrna_blast_db_path'),
                         unigene_blast_db_path => $self->o('unigene_blast_db_path'),
                         uniprot_blast_exe_path => $self->o('uniprot_blast_exe_path'),
                         vertrna_blast_exe_path => $self->o('vertrna_blast_exe_path'),
                         unigene_blast_exe_path => $self->o('unigene_blast_exe_path'),

                         genscan_path => $self->o('genscan_path'),

                         farm_user_name => $self->o('farm_user_name'),
                         genebuilder_id => $self->o('genebuilder_id'),
                         enscode_root_dir => $self->o('enscode_root_dir'),
                         output_path => $self->o('output_path'),
                         ftp_link_file => $self->o('ftp_link_file'),
                         contigs_source => $self->o('contigs_source'),
                         primary_assembly_dir_name => $self->o('primary_assembly_dir_name'),
                         reference_db_server => $self->o('reference_db_server'),
                         reference_db_port => $self->o('port'),
                         create_type => $self->o('create_type'),
                         user_w => $self->o('user'),
                         pass_w => $self->o('password'),
                         pipe_db_server => $self->o('pipe_db_server'),
                         production_db => $self->o('production_db'),
                         taxonomy_db => $self->o('taxonomy_db'),
                       },
        -rc_name    => 'default',
        -input_ids  => [ {} ],
        -flow_into  => {
                         1 => ['download_assembly_info'],
                         2 => ['download_contigs'],
                         3 => ['create_ensembl_db'],
                       },
      },

      {
        -logic_name => 'create_1mb_slice_ids',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveSubmitAnalysis',
        -parameters => {
                         coord_system_name => 'toplevel',
                         slice => 1,
                         slice_size => 1000000,
                         include_non_reference => 0,
                         top_level => 1,
                       },
        -flow_into => {
                        # FirstEF is left out here as it runs on repeats. Repeatmasker analyses flow into it
                        4 => ['run_repeatmasker','run_eponine','run_cpg','run_trnascan','run_dust','run_trf'],
                      },

      },

      {
        -logic_name => 'create_prediction_transcript_ids',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveSubmitAnalysis',
        -parameters => {
                         feature_type => 'prediction_transcript',
                         slice_to_feature_ids => 1,
                         prediction_transcript_logic_names => ['genscan'],
                       },
        -flow_into => {
                        4 => ['run_uniprot_blast','run_vertrna_blast','run_unigene_blast'],
                      },
        -rc_name    => 'default',
      },

###############################################################################
#
# ASSEMBLY LOADING ANALYSES
#
###############################################################################

      {
        -logic_name => 'download_assembly_info',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveDownloadNCBIFtpFiles',
        -parameters => {
                       },
        -rc_name    => 'default',
        -flow_into  => {
                         1 => ['populate_production_tables'],
                       },
      },

      {
        -logic_name => 'download_contigs',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveDownloadContigs',
        -parameters => {
                       },
        -rc_name    => 'default',
      },

      {
        -logic_name => 'create_ensembl_db',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveCreateDatabase',
        -parameters => {
                       },
        -rc_name    => 'default',
      },

      {
        -logic_name => 'populate_production_tables',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HivePopulateProductionTables',
        -parameters => {
                       },
        -rc_name    => 'default',
        -flow_into  => {
                         1 => ['load_contigs'],
                       },
         -wait_for => ['download_contigs','create_ensembl_db'],
      },

      {
        -logic_name => 'load_contigs',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveLoadSeqRegions',
        -parameters => {
                       },
        -rc_name    => 'default',
        -flow_into  => {
                         1 => ['load_assembly_info'],
                       },
      },

      {
        -logic_name => 'load_assembly_info',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveLoadAssembly',
        -parameters => {
                       },

        -rc_name    => 'default',
        -flow_into  => {
                         1 => ['set_toplevel'],
                       },
      },

      {
        -logic_name => 'set_toplevel',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveSetAndCheckToplevel',
        -parameters => {
                       },
        -rc_name    => 'default',
        -flow_into  => {
                         1 => ['load_meta_info'],
                       },
      },

      {
        -logic_name => 'load_meta_info',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveSetMetaAndSeqRegionSynonym',
        -parameters => {
                       },
        -rc_name    => 'default',
        -flow_into  => {
                          1 => ['create_1mb_slice_ids'],
                       },
      },

#      {
#        -logic_name => 'load_taxonomy_info',
#        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveLoadTaxonomyInfo',
#        -parameters => {
#                       },
#        -rc_name    => 'default',
#        -flow_into  => {
#                         1 => ['create_toplevel_ids'],
#                       },
#      },


###############################################################################
#
# REPEATMASKER ANALYSES
#
###############################################################################

      {
        -logic_name => 'run_repeatmasker',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveRepeatMasker',
        -parameters => {
                         logic_name => 'repeatmasker_'.$self->o('repeatmasker_library'),
                         module => 'HiveRepeatMasker',
                         repeatmasker_path => $self->o('repeatmasker_path'),
                         commandline_params => '-nolow -s -species "'.$self->o('repeatmasker_library').'" -engine "'.$self->o('repeatmasker_engine').'"',
                       },
        -rc_name    => 'repeatmasker',
        -flow_into => {
                        -1 => ['retry_run_repeatmasker_himem'],
                        -2 => ['retry_run_repeatmasker_long'],
                        4 => ['run_genscan','run_firstef'],
                      },

      },

      {
        -logic_name => 'retry_run_repeatmasker_himem',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveRepeatMasker',
        -parameters => {
                         logic_name => 'repeatmasker_'.$self->o('repeatmasker_library'),
                         module => 'HiveRepeatMasker',
                         repeatmasker_path => $self->o('repeatmasker_path'),
                         commandline_params => '-nolow -s -species "'.$self->o('repeatmasker_library').'" -engine "'.$self->o('repeatmasker_engine').'"',
                       },
        -rc_name    => 'repeatmasker_himem',
        -flow_into => {
                        -2 => ['retry_run_repeatmasker_long'],
                         4 => ['run_genscan','run_firstef'],
                      },

        -can_be_empty  => 1,
      },

      {
        -logic_name => 'retry_run_repeatmasker_long',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveRepeatMasker',
        -parameters => {
                         logic_name => 'repeatmasker_'.$self->o('repeatmasker_library'),
                         module => 'HiveRepeatMasker',
                         repeatmasker_path => $self->o('repeatmasker_path'),
                         commandline_params => '-nolow -s -species "'.$self->o('repeatmasker_library').'" -engine "'.$self->o('repeatmasker_engine').'"',
                       },
        -rc_name    => 'repeatmasker_long',
        -flow_into => {
                        4 => ['run_genscan','run_firstef'],
                      },
        -can_be_empty  => 1,
      },


###############################################################################
#
# GENSCAN ANALYSIS
#
##############################################################################

      {
        -logic_name => 'run_genscan',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveGenscan',
        -parameters => {
                         logic_name => 'genscan',
                         module => 'HiveGenscan',
                         genscan_path => $self->o('genscan_path'),
                         repeat_masking_logic_names => ['repeatmasker_'.$self->o('repeatmasker_library')],
                       },
        -rc_name    => 'genscan',
        -flow_into => {
                        4 => ['create_prediction_transcript_ids'],
                      },
      },


###############################################################################
#
# BLAST ANALYSES
#
##############################################################################

      {
        -logic_name => 'run_uniprot_blast',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveBlastGenscanPep',
        -parameters => {
                         blast_db_path => $self->o('uniprot_blast_db_path'),
                         blast_exe_path => $self->o('uniprot_blast_exe_path'),
                         commandline_params => '-cpus 3 -hitdist 40',
                         repeat_masking_logic_names => ['repeatmasker_'.$self->o('repeatmasker_library')],
                         prediction_transcript_logic_names => ['genscan'],
                         iid_type => 'feature_id',
                         logic_name => 'uniprot',
                         module => 'HiveBlastGenscanPep',
                         config_settings => $self->get_config_settings('HiveBlast','HiveBlastGenscanPep'),
                      },
        -rc_name    => 'blast',
      },

            {
        -logic_name => 'run_vertrna_blast',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveBlastGenscanDNA',
        -parameters => {
                         blast_db_path => $self->o('vertrna_blast_db_path'),
                         blast_exe_path => $self->o('vertrna_blast_exe_path'),
                         commandline_params => '-cpus 3 -hitdist 40',
                         repeat_masking_logic_names => ['repeatmasker_'.$self->o('repeatmasker_library')],
                         prediction_transcript_logic_names => ['genscan'],
                         iid_type => 'feature_id',
                         logic_name => 'vertrna',
                         module => 'HiveBlastGenscanDNA',
                         config_settings => $self->get_config_settings('HiveBlast','HiveBlastGenscanVertRNA'),
                      },
        -rc_name    => 'blast',
      },

      {
        -logic_name => 'run_unigene_blast',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveBlastGenscanDNA',
        -parameters => {
                         blast_db_path => $self->o('unigene_blast_db_path'),
                         blast_exe_path => $self->o('unigene_blast_exe_path'),
                         commandline_params => '-cpus 3 -hitdist 40',
                         prediction_transcript_logic_names => ['genscan'],
                         iid_type => 'feature_id',
                         repeat_masking_logic_names => ['repeatmasker_'.$self->o('repeatmasker_library')],
                         logic_name => 'unigene',
                         module => 'HiveBlastGenscanDNA',
                         config_settings => $self->get_config_settings('HiveBlast','HiveBlastGenscanUnigene'),
                      },
        -rc_name    => 'blast',
      },

###############################################################################
#
# SIMPLE FEATURE AND OTHER REPEAT ANALYSES
#
##############################################################################

      {
        -logic_name => 'run_dust',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveDust',
        -parameters => {
                         logic_name => 'dust',
                         module => 'HiveDust',
                         dust_path => $self->o('dust_path'),
                       },
        -rc_name    => 'simple_features',
      },

      {
        -logic_name => 'run_trf',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveTRF',
        -parameters => {
                         logic_name => 'trf',
                         module => 'HiveTRF',
                         trf_path => $self->o('trf_path'),
                       },
        -rc_name    => 'simple_features',
      },

      {
        -logic_name => 'run_eponine',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveEponine',
        -parameters => {
                         logic_name => 'eponine',
                         module => 'HiveEponine',
                         eponine_path => $self->o('eponine_path'),
                         commandline_params => '-epojar=> /software/ensembl/genebuild/usrlocalensembllib/eponine-scan.jar, -threshold=> 0.999',
                       },
        -rc_name    => 'simple_features',
      },

      {
        -logic_name => 'run_firstef',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveFirstEF',
        -parameters => {
                         logic_name => 'firstef',
                         module => 'HiveFirstEF',
                         firstef_path => $self->o('firstef_path'),
                         commandline_params => '-repeatmasked',
                       },
        -rc_name    => 'simple_features',
      },

      {
        -logic_name => 'run_cpg',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveCPG',
        -parameters => {
                         logic_name => 'cpg',
                         module => 'HiveCPG',
                         cpg_path => $self->o('cpg_path'),
                       },
        -rc_name    => 'simple_features',
      },

      {
        -logic_name => 'run_trnascan',
        -module     => 'Bio::EnsEMBL::Analysis::Hive::RunnableDB::HiveAssemblyLoading::HiveTRNAScan',
        -parameters => {
                         logic_name => 'trnascan',
                         module => 'HiveTRNAScan',
                         trnascan_path => $self->o('trnascan_path'),
                       },
        -rc_name    => 'simple_features',
      },

    ];
}



sub pipeline_wide_parameters {
    my ($self) = @_;

    return {
        %{ $self->SUPER::pipeline_wide_parameters() },  # inherit other stuff from the base class
    };
}

# override the default method, to force an automatic loading of the registry in all workers
#sub beekeeper_extra_cmdline_options {
#    my $self = shift;
#    return "-reg_conf ".$self->o("registry");
#}

sub resource_classes {
    my $self = shift;
    return {
      'default' => { LSF => '-q normal -M900 -R"select[mem>900] rusage[mem=900,myens_build12tok=10,myens_build13tok=10]"' },
      'repeatmasker' => { LSF => '-q normal -M3900 -R"select[mem>3900] rusage[mem=3900,myens_build12ok=10,myens_build13tok=10]"' },
      'repeatmasker_himem' => { LSF => '-q normal -M6900 -R"select[mem>6900] rusage[mem=6900,myens_build12tok=10,myens_build13tok=10]"' },
      'repeatmasker_long' => { LSF => '-q long -M6900 -R"select[mem>6900] rusage[mem=6900,myens_build12tok=10,myens_build13tok=10]"' },
      'simple_features' => { LSF => '-q normal -M2900 -R"select[mem>2900] rusage[mem=2900,myens_build12tok=10,myens_build13tok=10]"'},
      'genscan' => { LSF => '-q normal -M2900 -R"select[mem>2900] rusage[mem=2900,myens_build12tok=10,myens_build13tok=10]"' },
      'blast' => { LSF => '-q normal -M3900 -n 3 -R "select[mem>3900] rusage[mem=3900,myens_build12tok=10,myens_build13tok=10] span[hosts=1]"' },
    }
}

sub get_config_settings {

   # Shift in the group name (a hash that has a collection of logic name hashes and a default hash)
   # Shift in the logic name of the specific analysis
   my $self = shift;
   my $config_group = shift;
   my $config_logic_name = shift;

   # And additional hash keys will be stored in here
   my @additional_configs = @_;

   # Return a ref to the master hash for the group using the group name
   my $config_group_hash = $self->master_config_settings($config_group);
   unless(defined($config_group_hash)) {
     die "You have asked for a group name in master_config_settings that doesn't exist. Group name:\n".$config_group;
   }
   # Final hash is the hash reference that gets returned. It is important to note that the keys added have
   # priority based on the call to this subroutine, with priority from left to right. Keys assigned to
   # $config_logic_name will have most priority, then keys in any additional hashes, then keys from the
   # default hash. A default hash key will never override a $config_logic_name key
   my $final_hash;

   # Add keys from the logic name hash
   my $config_logic_name_hash = $config_group_hash->{$config_logic_name};
   unless(defined($config_logic_name_hash)) {
     die "You have asked for a logic name hash that doesn't exist in the group you specified.\n".
         "Group name:\n".$config_group."\nLogic name:\n".$config_logic_name;
   }

   $final_hash = $self->add_keys($config_logic_name_hash,$final_hash);

   # Add keys from any additional hashes passed in, keys that are already present will not be overriden
   foreach my $additional_hash (@additional_configs) {
     my $config_additional_hash = $config_group_hash->{$additional_hash};
     $final_hash = $self->add_keys($config_additional_hash,$final_hash);
   }

   # Default is always loaded and has the lowest key value priority
   my $config_default_hash = $config_group_hash->{'Default'};
   $final_hash = $self->add_keys($config_default_hash,$final_hash);

   return($final_hash);
}

sub add_keys {
  my ($self,$hash_to_add,$final_hash) = @_;

  foreach my $key (keys(%$hash_to_add)) {
    unless(exists($final_hash->{$key})) {
      $final_hash->{$key} = $hash_to_add->{$key};
    }
  }

  return($final_hash);
}

sub master_config_settings {

  my ($self,$config_group) = @_;
  my $master_config_settings = {

  HiveBlast => {

  DEFAULT => {
      BLAST_PARSER => 'Bio::EnsEMBL::Analysis::Tools::BPliteWrapper',
      PARSER_PARAMS => {
        -regex => '^(\w+)',
        -query_type => undef,
        -database_type => undef,
      },
      BLAST_FILTER => undef,
      FILTER_PARAMS => {},
      BLAST_PARAMS => {
        -unknown_error_string => 'FAILED',
        -type => 'wu',
      }
  },

  HiveBlastGenscanPep => {
    BLAST_PARSER => 'Bio::EnsEMBL::Analysis::Tools::FilterBPlite',
    PARSER_PARAMS => {
                       -regex => '^(\w+\W\d+)',
                       -query_type => 'pep',
                       -database_type => 'pep',
                       -threshold_type => 'PVALUE',
                       -threshold => 0.01,
                     },
    BLAST_FILTER => 'Bio::EnsEMBL::Analysis::Tools::FeatureFilter',
    FILTER_PARAMS => {
                       -min_score => 200,
                       -prune => 1,
                     },
  },

    HiveBlastGenscanVertRNA => {
    BLAST_PARSER => 'Bio::EnsEMBL::Analysis::Tools::FilterBPlite',
    PARSER_PARAMS => {
                       -regex => '^(\w+\W\d+)',
                       -query_type => 'pep',
                       -database_type => 'dna',
                       -threshold_type => 'PVALUE',
                       -threshold => 0.001,
                     },
    BLAST_FILTER => 'Bio::EnsEMBL::Analysis::Tools::FeatureFilter',
    FILTER_PARAMS => {
                       -prune => 1,
                     },
  },

  HiveBlastGenscanUnigene => {
    BLAST_PARSER => 'Bio::EnsEMBL::Analysis::Tools::FilterBPlite',
    PARSER_PARAMS => {
                       -regex => '\/ug\=([\w\.]+)',
                       -query_type => 'pep',
                       -database_type => 'dna',
                       -threshold_type => 'PVALUE',
                       -threshold => 0.001,
                     },
    BLAST_FILTER => 'Bio::EnsEMBL::Analysis::Tools::FeatureFilter',
    FILTER_PARAMS => {
                       -prune => 1,
                     },
    },
    },

  };

  return($master_config_settings->{$config_group});

}

1;
